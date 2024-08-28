//
//  Outbrain.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 18/06/2023.
//

import Foundation
import UIKit

public class Outbrain {

    // MARK: OB Instance Variables

    // current SDK version
    static let OB_SDK_VERSION = "5.0.12"

    // Logger
    static var logger = OBLogger()
    static var isInitialized = false
    static var partnerKey: String? // partner key will use to resolve the publisher
    static var customUserId: String?
    static var lastTParam: String?
    static var lastApvParam: Bool?
    
    public static var testMode: Bool = false
    public static var testRTB: Bool = false
    public static var testLocation: String?
    

    // init outbrain sdk with a partner key
    public static func initializeOutbrain(withPartnerKey partnerKey: String) {
        logger.log("Outbrain SDK initilized with partner key: \(partnerKey)")
        guard !isInitialized else { return }
        
        self.partnerKey = partnerKey
        isInitialized = true
    }

    
    // check if OutbrainSDK has initiated with a key
    public static func checkInitiated() -> OBError? {
        guard !isInitialized else { return nil }
        
        logger.error("Outbrain SDK hasn't initiated with a partner key")
        let err = OBError.generic(
            message: "Outbrain SDK hasn't initiated with a partner key",
            key: .generic,
            code: .generic
        )
        return err
    }
    

    // MARK: Fetch Recommendations for requsest - callback or delegate
    public static func fetchRecommendations(
        for request: OBRequest,
        with callback: @escaping (OBRecommendationResponse) -> Void
    ) {
        logger.debug("fetchRecommendations for widgetId \(request.widgetId) & url \(String(describing: request.url))")
        // check initilized
        
        
        if let notInitilized = Outbrain.checkInitiated() {
            // create an empty resposen with the corresponding error
            let failedRes = OBRecommendationResponse(
                request: [:],
                settings: [:],
                viewabilityActions: nil,
                recommendations: [],
                error: notInitilized
            )

            callback(failedRes)
            return
        }

        
        OBQueueManager.shared.enqueueFetchRecsRequest {
            OBRequestHandler(request).fetchRecs(callback: callback)
        }
    }

    
    public static func fetchRecommendations(
        for request: OBRequest,
        with delegate: OBResponseDelegate
    ) {
        logger.debug("fetchRecommendations for widgetId \(request.widgetId) & url \(String(describing: request.url))")
        
        if let error = Outbrain.checkInitiated() {
            delegate.outbrainDidReceiveResponse(withSuccess: .init(
                request: [:],
                settings: [:],
                viewabilityActions: nil,
                recommendations: [],
                error: error
            ))
            return
        }

        OBQueueManager.shared.enqueueFetchRecsRequest {
            OBRequestHandler(request).fetchRecs(delegate: delegate)
        }
    }
    

    // MARK: Rec Click
    public static func getUrl(_ rec: OBRecommendation) -> URL? {
        logger.debug("getting click url for \(rec.isPaidLink ? "paid" : "organic") rec \(String(describing: rec.position))")

        // rec url
        guard let url = rec.url else {
            return nil
        }

        // rec orig_url
        guard let origUrl = rec.origUrl else {
            return URL(string: url)
        }

        // if rec is paid return the url
        if rec.isPaidLink {
            return URL(string: url)
        }

        // else make a request to the click url & return the orig url
        var reqUrl = URLComponents(string: url)!

        // add noRedirect param
        var queryItems = reqUrl.queryItems ?? []
        queryItems.append(URLQueryItem(name: "noRedirect", value: "true"))
        reqUrl.queryItems = queryItems

        // make the call
        if let clickUrl = reqUrl.url {
            let task = URLSession.shared.dataTask(with: clickUrl)
            task.resume()
        }

        logger.debug("organic link clicked: \(String(describing: reqUrl.url))")

        // return orig url
        return URL(string: origUrl)
    }

    
    // MARK: What-Is
    public static func getOutbrainAboutURL() -> URL? {
        let baseUrl = "https://www.outbrain.com/what-is/"

        // enrich params with some data - oo & userId
        guard var whatisUrl = URLComponents(string: baseUrl) else {
            return URL(string: baseUrl)
        }
        
        whatisUrl.queryItems = [
            URLQueryItem(name: "doo", value: OBRequestHandler.getOptedOut() ? "true" : "false"),
            URLQueryItem(name: "apiUserId", value: OBRequestHandler.getApiUserId())
        ]

        return whatisUrl.url
    }
    
    
    public static func getAboutURL() -> URL? {
        return Outbrain.getOutbrainAboutURL()
    }

    
    // MARK: Viewability
    // refresh OBLabel viewability with a new request
    public static func configureViewabilityPerListing(for view: UIView, withRec rec: OBRecommendation) {
        // start viewability chcking
        OBViewbailityManager.shared.startReportViewability(withTimeInterval: 2000)

        // configure viewability for a view with a rec
        OBViewbailityManager.shared.configureViewabilityPerListing(for: view, withRec: rec)
    }

    
    // MARK: Logging
    // for debuging purposes, print all stored logs
    public static func printLogs(domain: String? = nil) {
        self.logger.printLogs(domain: domain)
    }
    
    
    // MARK: - Testing
    public static func setTestMode(_ testMode: Bool) {
        #if DEBUG
        self.testMode = testMode
        #endif
    }
    
    
    public static func testRTB(_ testRTB: Bool) {
        self.testRTB = testRTB
    }
    
    
    public static func testLocation(_ testLocation: String) {
        self.testLocation = testLocation
    }
}
