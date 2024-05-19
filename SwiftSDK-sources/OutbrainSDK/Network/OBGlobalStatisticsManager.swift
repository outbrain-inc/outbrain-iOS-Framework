//
//  OBGlobalStatisticsManager.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 27/06/2023.
//

import Foundation

let thirtyMinutesInSeconds: Float = 30.0 * 60.0 // 30 minutes

public struct OBGlobalStatisticsManager {
    var globalStatisticsDataMap: [String: OBGlobalStatisticsData] = [:]
    var obLabelkeyToRequestIdKeyMap: [String: String] = [:]
    var reqIdAlreadyReportedArray: [String] = []
    
    static public var shared = OBGlobalStatisticsManager()
    
    private init() {}
    
    // MARK: Reporting
    
    // report served
    mutating func reportServed(request: OBRequest, response: OBRecommendationResponse, timestamp requestStartDate: Date) {
        // Check if viewability is enabled
        guard isGlobalStatsticsEnabled(),
              let rid = response.request["req_id"] as? String,
              let reportServedUrl = response.viewabilityActions?.reportServed,
              let reportViewedUrl = response.viewabilityActions?.reportViewed,
              let optedOut = response.request["oo"] as? Bool
        else { return }
        
        // Create the viewability data object
        let viewabilityData = OBGlobalStatisticsData(
            reportServedUrl: reportServedUrl,
            reportViewedUrl: reportViewedUrl,
            rId: rid,
            requestStartDate: requestStartDate,
            optedOut: optedOut
        )
        
        // Add the viewability data object to the map
        let viewabilityKeyForRequestId = self.globalStatsticsKey(forRequestId: rid)
        self.globalStatisticsDataMap[viewabilityKeyForRequestId] = viewabilityData
        
        // Add the viewability key to the request id map
        let viewabilityKeyForOBRequest = self.globalStatsticsKey(forRequest: request)
        self.obLabelkeyToRequestIdKeyMap[viewabilityKeyForOBRequest] = viewabilityKeyForRequestId
        
        // take timestamp
        let timeNow = Date()
        
        // calculate time to process request
        let timeIntervalSinceRequestStart = timeNow.timeIntervalSince(requestStartDate)
        
        // convert to milliseconds
        let timeToProcessRequest = String(Int(timeIntervalSinceRequestStart * 1000))
        
        // check report served URL
        if viewabilityData.reportServedUrl == nil {
            Outbrain.logger.error("report recs received - reportServedUrl is nil", domain: "global-statistics")
            return
        }
        
        // if served url does not exist, return
        guard let servedUrl = globalStatsticsUrlWithMandatoryParams(url: viewabilityData.reportServedUrl!, tmParam: timeToProcessRequest, isOptedOut: viewabilityData.optedOut!) else {
            return
        }
                
        // create the request
        let task = URLSession.shared.dataTask(with: servedUrl)
        task.resume()
        
        Outbrain.logger.debug("report recs received - servedUrl: \(servedUrl)", domain: "global-statistics")
    }
    
    // report viewed for request id
    mutating func reportViewed(forRequestId reqId: String) {
        let viewabilityKeyForRequestId = self.globalStatsticsKey(forRequestId: reqId)
        self.reportViewed(forKey: viewabilityKeyForRequestId)
    }
    
    // report viewed for key
    mutating func reportViewed(forKey key: String) {
        // get the viewability data object
        var viewabilityKey: String = key
        if let requestIdKeyAssociatedWithOBLabel = self.obLabelkeyToRequestIdKeyMap[key] {
            viewabilityKey = requestIdKeyAssociatedWithOBLabel
        }
        
        if let viewabilityData = self.globalStatisticsDataMap[viewabilityKey] {
            guard let reqId = viewabilityData.rId else { return }
            
            // check if request id was already reported
            if self.reqIdAlreadyReportedArray.contains(reqId) {
                return
            }
            
            // calc time since request was sent
            guard let requestStartDate = viewabilityData.requestStartDate else { return }
            let timeNow = Date()
            let executionTimeInterval = timeNow.timeIntervalSince(requestStartDate)
            
            // check if time since request was sent is more than 30 minutes
            if Float(executionTimeInterval) > thirtyMinutesInSeconds {
                return
            }
            
            // convert to milliseconds
            let executionTime = String(Int(executionTimeInterval * 1000))
            
            // add request id to already reported array
            if let rId = viewabilityData.rId {
                self.reqIdAlreadyReportedArray.append(rId)
            }
            
            // check report viewed URL
            guard let reportViewedUrl = viewabilityData.reportViewedUrl else {
                Outbrain.logger.error("report recs shown - reportViewedUrl is nil", domain: "global-statistics")
                return
            }
            
            // enrich the URL with mandatory params
            guard let viewabilityUrl = globalStatsticsUrlWithMandatoryParams(url: reportViewedUrl, tmParam: executionTime, isOptedOut: viewabilityData.optedOut!) else {
                return
            }
            
            // make the request
            let task = URLSession.shared.dataTask(with: viewabilityUrl)
            task.resume()
            
            Outbrain.logger.debug("report recs shown - reportViewedUrl: \(viewabilityUrl)", domain: "global-statistics")
        }
    }
    
    // MARK: Pixels
    
    // Fire pixels for a response
    func firePixels(for response: OBRecommendationResponse) {
        if response.recommendations.isEmpty {
            return
        }
        
        for rec in response.recommendations {
            firePixels(for: rec)
        }
    }
    
    // Fire pixels for a recommendation
    func firePixels(for rec: OBRecommendation) {
        guard let pixels = rec.pixels else {
            return
        }

        for pixel in pixels {
            let pixelComponent = URLComponents(string: pixel)
            if let pixelUrl = pixelComponent?.url {
                let task = URLSession.shared.dataTask(with: pixelUrl) { _, _, error in
                    if error != nil {
                        Outbrain.logger.error("pixel error: \(pixelUrl)", domain: "global-statistics")
                    } else {
                        Outbrain.logger.debug("fired pixel: \(pixelUrl)", domain: "global-statistics")
                    }
                }
                task.resume()
            }
        }
    }
    
    // MARK: - Global Stattistics Settings
    
    // Check global statistics setting
    func checkAndUpdateGlobalStatisticsSetting(_ res: OBRecommendationResponse) {
        var isEnabled = true
        
        if res.settings.isEmpty {
            isEnabled = false
        }
        
        if let isGlobalWidgetStatistics = res.settings["globalWidgetStatistics"] as? Bool {
            isEnabled = isGlobalWidgetStatistics
        }
        
        self.updateGlobalStatsticsSetting(isEnabled, key: GS_KEYS.ENABLED)
    }
    
    // Update global statistics setting
    func updateGlobalStatsticsSetting(_ value: Bool, key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    // check if global statistics is enabled
    func isGlobalStatsticsEnabled() -> Bool {
        if let value = UserDefaults.standard.object(forKey: GS_KEYS.ENABLED) as? Bool {
            return value
        }
        return true
    }
    
    // threshold for viewability
    func viewabilityThresholdMilliseconds() -> Int {
        var value: Int = 1000

        if let storedValue = UserDefaults.standard.object(forKey: GS_KEYS.THRESHOLD) as? Int {
            value = storedValue
        }
                
        return value
    }
    
    // get global statistics key for request id
    func globalStatsticsKey(forRequestId reqId: String) -> String {
        return String(format: GS_KEYS.REQ_ID, reqId)
    }
    
    // get global statistics key for url
    func globalStatsticsKey(forUrl url: String, widgetId: String, widgetIndex: String) -> String {
        let urlHash = url.hashValue
        return String(format: GS_KEYS.URL_HASH_WIDGET_ID, urlHash, widgetId, widgetIndex)
    }
    
    // get global statistics key for request
    func globalStatsticsKey(forRequest request: OBRequest) -> String {
        var url = request.url
        
        // if platforms request - check if using bundle, content or portal url
        if let platformsRequest = request as? OBPlatformsRequest {
            if platformsRequest.isUsingBundleUrl {
                url = platformsRequest.bundleUrl
            } else if platformsRequest.isUsingContentUrl {
                url = platformsRequest.contentUrl
            } else if platformsRequest.isUsingPortalUrl {
                url = platformsRequest.portalUrl
            }
        }
        
        return globalStatsticsKey(forUrl: url!, widgetId: request.widgetId, widgetIndex: request.idx!)
    }
    
    // build global statistics URL with mandatory params
    func globalStatsticsUrlWithMandatoryParams(url: String, tmParam: String, isOptedOut: Bool) -> URL? {
        guard var urlComponents = URLComponents(string: url) else { return nil }
        
        var newQueryItems = urlComponents.queryItems ?? []
        
        newQueryItems = newQueryItems.filter { queryItem in
            return queryItem.name != "tm"
        }
        
        // add opt out and tm params
        let optOutQueryItem = URLQueryItem(name: "oo", value: isOptedOut ? "true" : "false")
        let tmQueryItem = URLQueryItem(name: "tm", value: tmParam)
        
        newQueryItems.append(optOutQueryItem)
        newQueryItems.append(tmQueryItem)
        
        // update url components
        urlComponents.queryItems = newQueryItems
        return urlComponents.url
    }
    
    // get initialization time for request id
    func initializationTime(forReqId reqId: String) -> Date? {
        let viewabilityKey = globalStatsticsKey(forRequestId: reqId)
        if let viewabilityData = self.globalStatisticsDataMap[viewabilityKey] {
            return viewabilityData.requestStartDate
        } else {
            return Date()
        }
    }
}

enum GS_KEYS {
    static let ENABLED = "globalStatisticsEnabledKey"
    static let THRESHOLD = "globalStatisticsThresholdKey"
    static let URL_HASH_WIDGET_ID = "OB_Viewability_Key_%lu_%@_%ld"
    static let REQ_ID = "OB_Viewability_Key_%@"
}
