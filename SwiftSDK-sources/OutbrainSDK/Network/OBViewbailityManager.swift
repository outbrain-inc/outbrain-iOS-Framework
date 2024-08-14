//
//  OBViewbailityManager.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 02/07/2023.
//

import Foundation
import UIKit

public class OBViewbailityManager {
    var reportViewabilityTimer: Timer?
    var itemAlreadyReportedMap: [String: Bool] = [:]
    var itemsToReportMap: [String: Any] = [:]
    var obViewsData: [String: OBViewData?] = [:]
    var isLoading: Bool = false
    
    static public let shared = OBViewbailityManager()
    
    private init(){}
    
    // MARK: Configure Viewability
    
    // Configure viewability per listing for a given view
    func configureViewabilityPerListing(for view: UIView, withRec rec: OBRecommendation) {
        // get the position
        let position = rec.position ?? "0"
        
        // get the request id
        let requestId = rec.reqId!
        
        // remove the view if exists
        if let existingOBView = view.viewWithTag(OB_VIEWABILITY_CONSTANTS.DEFAULT_TAG) as? OBView {
            existingOBView.removeFromSuperview()
        }
        
        // Check if the item was already reported
        if !isAlreadyReported(for: requestId, position: position) {
            
            // get the initialization time
            if let initializationTime = OBGlobalStatisticsManager.shared.initializationTime(forReqId: requestId) {
                // create the ob view
                let obView = OBView(frame: view.bounds)
                
                // set the tag
                obView.tag = OB_VIEWABILITY_CONSTANTS.DEFAULT_TAG
                
                // set opaque to false
                obView.isOpaque = false
                
                // register the view
                registerOBView(obView, positions: [position], requestId: requestId, initializationTime: initializationTime)
                
                // set the view as not user interaction enabled
                obView.isUserInteractionEnabled = false
                
                // add the view
                view.addSubview(obView)
            }
        }
    }

    // register the OB view
    func registerOBView(_ obView: OBView, positions: [String]?, requestId: String?, initializationTime: Date?) {
        // get the position
        let pos = (positions != nil && positions!.count > 0) ? positions![0] : "0"
        
        // get the request id
        guard let requestId = requestId else {
            return
        }
        
        // get the key
        let key = viewabilityKey(for: requestId, position: pos)
        obView.key = key
        
        registerViewabilityKey(
            key: key,
            positions: positions,
            requestId: requestId,
            initializationTime: initializationTime
        )
    }
    
    func registerViewabilityKey(
        key: String,
        positions: [String]?,
        requestId: String,
        initializationTime: Date?
    ) {
        // create the view data
        var obViewData: OBViewData = OBViewData()
        
        // set the positions
        if let positions = positions {
            obViewData.positions = positions
        }
        
        // set the request id
        if !requestId.isEmpty {
            obViewData.requestId = requestId
        }
        
        // set the initialization time
        if let initializationTime = initializationTime {
            obViewData.initializationTime = initializationTime
        }
        
        // set the view data
        self.obViewsData[key] = obViewData
    }

    // MARK: Viewability Reporting
    
    // report viewability for a given OB view
    func reportViewability(for obView: OBView) {
        // verify the ob view data
        guard let key = obView.key else { return }
        reportViewability(for: key)
    }
    
    
    func reportViewability(for key: String) {
        guard let obViewData = self.obViewsData[key] as? OBViewData,
              let positions = obViewData.positions,
              let requestId = obViewData.requestId,
              let initializationTime = obViewData.initializationTime else {
            return
        }
        
        // calc the time elapsed
        let timeNow = Date()
        let timeInterval = timeNow.timeIntervalSince(initializationTime)
        let timeElapsedMillis = Int(timeInterval * 1000)
        
        // iterate over the positions and add the items to report map
        for pos in positions {
            let key = viewabilityKey(for: requestId, position: pos)
            self.itemAlreadyReportedMap[key] = true
            
            var itemMap: [String: Any] = [:]
            if let position = Int(pos) {
                itemMap["position"] = position
            }
            itemMap["timeElapsed"] = timeElapsedMillis
            itemMap["requestId"] = requestId
            
            self.itemsToReportMap[key] = itemMap
            Outbrain.logger.debug("added viewability report: \(itemMap)", domain: "viewability-mananger")
        }
        
        // Viewability widget level (eT=3)
        OBGlobalStatisticsManager.shared.reportViewed(forRequestId: requestId)
    }

    // set timer that check for viewability reporting
    func startReportViewability(withTimeInterval reportingIntervalMillis: Int) {
        // if the timer is already running, return
        if self.reportViewabilityTimer != nil {
            return
        }
        
        // create the timer
        let reportingIntervalSec = TimeInterval(reportingIntervalMillis) / 1000.0
        
        // set the timer
        self.reportViewabilityTimer = Timer(timeInterval: reportingIntervalSec,
                                            target: self,
                                            selector: #selector(report),
                                            userInfo: nil,
                                            repeats: true)
        
        // set the tolerance
        self.reportViewabilityTimer?.tolerance = reportingIntervalSec * 0.5
        
        // add the timer to the run loop
        RunLoop.main.add(self.reportViewabilityTimer!, forMode: .common)
    }

    
    // report viewability
    @objc func report() {
        // if there is nothing to report, return
        if self.itemsToReportMap.count == 0 || self.isLoading {
            return
        }
        
        // create the url
        guard let url = URL(string: OBAppleAdIdUtil.isOptedOut ? OB_VIEWABILITY_CONSTANTS.LOG_VIEWABILITY_URL : OB_VIEWABILITY_CONSTANTS.T_LOG_VIEWABILITY_URL) else {
            return
        }
        
        // get the keys
        let keys = Array(self.itemsToReportMap.keys)
        
        // set the loading to true
        self.isLoading = true
        
        // create the request
        var request = URLRequest(url: url)
        
        // set methid to post
        request.httpMethod = "POST"
        
        // prepare the json data
        let jsonData: Data
        do {
            // get the json data
            jsonData = try JSONSerialization.data(withJSONObject: Array(self.itemsToReportMap.values), options: [])
            
            // set the request body
            request.httpBody = jsonData
        } catch {
            Outbrain.logger.error("Error serializing JSON data: \(error)", domain: "viewability-mananger")
            
            // set the loading to false
            self.isLoading = false
            
            // on error, return
            return
        }
        
        // make the request
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            // if self is nil, return -  can happen if the view controller was released
            guard let self = self else {
                return
            }
            
            Outbrain.logger.debug("report viewability: \(self.itemsToReportMap.values)", domain: "viewability-mananger")
            
            // if there is an error, print it and return
            if let error = error {
                Outbrain.logger.error("Error report viewability per listing: \(error.localizedDescription)", domain: "viewability-mananger")
            } else {
                // else remove the keys from the items to report map
                if !keys.isEmpty {
                    for key in keys {
                        self.itemsToReportMap.removeValue(forKey: key)
                    }
                }
            }
                        
            // set the loading to false
            self.isLoading = false
        }
        
        // start the request
        task.resume()
    }
    
    //  MARK: - Helpers
    
    // check if the viewability was already reported for the given request id and position
    func isAlreadyReported(for requestId: String, position pos: String) -> Bool {
        let key = viewabilityKey(for: requestId, position: pos)
        return self.itemAlreadyReportedMap[key] != nil
    }
    
    // generate a unique key for the given request id and position
    func viewabilityKey(for requestId: String, position pos: String) -> String {
        return String(format: OB_VIEWABILITY_CONSTANTS.VIEWABILITY_KEY_FOR_REQUEST_ID_POSITION, requestId, pos)
    }
}

enum OB_VIEWABILITY_CONSTANTS  {
    static let DEFAULT_TAG = 12345678
    static let LOG_VIEWABILITY_URL = "https://log.outbrainimg.com/api/loggerBatch/log-viewability"
    static let T_LOG_VIEWABILITY_URL = "https://t-log.outbrainimg.com/api/loggerBatch/log-viewability"
    static let VIEWABILITY_KEY_FOR_REQUEST_ID_POSITION = "OB_Viewability_Key_%@_%@"
}
