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
    static let OB_SDK_VERSION = "5.0.3"

    // Logger
    static var logger = OBLogger()

    // Initiated flag
    static var WAS_INITIALIZED = false

    // partner key will use to resolve the publisher
    static var partnerKey: String?

    // manual set user id
    static var customUserId: String?

    // store last t param
    static var lastTParam: String?

    // store last apv param
    static var lastApvParam: Bool?
    
    // store test mode
    public static var testMode: Bool = false
    
    // store test RTB
    public static var testRTB: Bool = false
    
    // set test mode
    public static func setTestMode(testMode: Bool) {
        self.testMode = testMode
    }
    
    // set test rtb mode
    public static func testRTB(testRTB: Bool) {
        self.testRTB = testRTB
    }

    // init outbrain sdk with a partner key
    public static func initializeOutbrain(withPartnerKey partnerKey: String) {
        logger.log("Outbrain SDK initilized with partner key: \(partnerKey)")
        if !self.WAS_INITIALIZED {
            self.partnerKey = partnerKey
            self.WAS_INITIALIZED = true
        }
    }

    // check if OutbrainSDK has initiated with a key
    public static func checkInitiated() -> OBError? {
        if !self.WAS_INITIALIZED {
            logger.error("Outbrain SDK hasn't initiated with a partner key")
            let err = OBError.genericError(message: "Outbrain SDK hasn't initiated with a partner key", key: .genericError, code: .genericErrorCode)
            return err
        }
        return nil
    }

    // MARK: Fetch Recommendations for requsest - callback or delegate

    public static func fetchRecommendations(for request: OBRequest, with callback: @escaping (OBRecommendationResponse) -> Void){
        logger.debug("fetchRecommendations for widgetId \(request.widgetId) & url \(String(describing: request.url))")
        // check initilized
        if let notInitilized = Outbrain.checkInitiated() {
            // create an empty resposen with the corresponding error
            let failedRes = OBRecommendationResponse(request: [:], settings: [:], viewabilityActions: nil, recommendations: [], error: notInitilized)

            // run the cb with the error
            callback(failedRes)

            return
        }

        let requestHandler = OBRequestHandler(request)
        OBQueueManager.shared.enqueueFetchRecsRequest {
            requestHandler.fetchRecs(callback: callback)
        }

    }

    public static func fetchRecommendations(for request: OBRequest, with delegate: OBResponseDelegate){
        logger.debug("fetchRecommendations for widgetId \(request.widgetId) & url \(String(describing: request.url))")

        let requestHandler = OBRequestHandler(request)

        // check initilized
        if let notInitilized = Outbrain.checkInitiated() {
            // create an empty resposen with the corresponding error
            let failedRes = OBRecommendationResponse(request: [:], settings: [:], viewabilityActions: nil, recommendations: [], error: notInitilized)

            // call the fetch failed for delegation
            requestHandler.fetchRecsFailed(delegate: delegate, response: failedRes)
            return
        }

        OBQueueManager.shared.enqueueFetchRecsRequest {
            requestHandler.fetchRecs(delegate: delegate)
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

    public static func getOutbrainAboutURL() -> String {
        let baseUrl = "https://www.outbrain.com/what-is/"

        // enrich params with some data - oo & userId
        guard var whatisUrl = URLComponents(string: baseUrl) else {
            return baseUrl
        }
        whatisUrl.queryItems = [
            URLQueryItem(name: "doo", value: OBRequestHandler.getOptedOut()),
            URLQueryItem(name: "apiUserId", value: OBRequestHandler.getApiUserId())
        ]

        return whatisUrl.url?.absoluteString ?? baseUrl
    }
    
    public static func getAboutURL() -> String {
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

    public static func openAppInstallRec(_ rec: OBRecommendation, in: UIViewController) {}

}
