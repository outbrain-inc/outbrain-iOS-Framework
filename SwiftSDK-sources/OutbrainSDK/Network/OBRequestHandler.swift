//
//  OBRequestHandler.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation
import UIKit

public struct OBRequestHandler {
    // perform odb request based on this request struct
    let request: OBRequest
        
    // if platforms getter
    var isPlatformsRequest: Bool {
        return (request as? OBPlatformsRequest) != nil
    }
    
    init(_ request: OBRequest) {
        self.request = request
    }
    
    // MARK: Fetch Recomendations - make http request for fetching recommendations from odb, option to pass callback or delegate that will resolve to OBResponse
    
    // callback
    func fetchRecs(callback: @escaping (OBRecommendationResponse) -> Void) {
        guard let finalUrl = buildOdbParams() else {
            return
        }
        performFetchTask(with: finalUrl, callback: callback)
    }

    // delegate on success
    func fetchRecs(delegate: OBResponseDelegate) {
        guard let finalUrl = buildOdbParams() else {
            return
        }
        performFetchTask(with: finalUrl, callback: delegate.outbrainDidReceiveResponse)
    }
    
    func performFetchTask(with url: URL, callback: @escaping (OBRecommendationResponse) -> Void) {
        Outbrain.logger.debug("fetch recs - task added", domain: "request-handler")
        
        // init error reporting data
        OBErrorReport.shared.resetReport()
        OBErrorReport.shared.odbRequestUrlParamValue = self.request.url
        OBErrorReport.shared.widgetId = self.request.widgetId
        
        // using semaphore to ensure serial execution
        let sema = DispatchSemaphore(value: 0)
        
        DispatchQueue.main.async {
            // set the request start date
            self.request.startDate = Date()
            
            Outbrain.logger.log("fetch recs - task started for url \(url.absoluteString)", domain: "request-handler")

            // http call task
            var request = URLRequest(url: url)
            
            // trace mode if debug
            #if DEBUG
                request.setValue("true", forHTTPHeaderField: "x-trace")
            #endif
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                // trace mode if debug
                #if DEBUG
                if #available(iOS 13.0, *) {
                    if let debugRes = response as? HTTPURLResponse {
                        if let traceID = debugRes.value(forHTTPHeaderField: "x-traceid") {
                            // Access the trace ID here
                            Outbrain.logger.debug("fetch recs - trace id: \(traceID)", domain: "request-handler")
                        }
                    }
                }
                #endif
                
                do {
                    try self.handleResponse(data: data, response: response, error: error, callback: callback)
                } catch {
                    Outbrain.logger.error("handle response failed: \(error)")
                }
                
                // send semaphore signal to proceed to the next operation
                sema.signal()
                
                Outbrain.logger.debug("fetch recs - task finished", domain: "request-handler")
            }
            
            // make the http call
            task.resume()
        }
        
        // wait for the next operation
        let _ = sema.wait(timeout: .distantFuture)
    }
    
    // MARK: Handle Response - checks if got valid response back from the server
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?, callback: @escaping (OBRecommendationResponse) throws -> Void) throws {
        // report error to widget monitor if error
        defer {
            if OBErrorReport.shared.errorMessage != nil {
                OBErrorReport.shared.reportErrorToServer()
            }
        }
        
        // reset t & apv params
        if request.idx == "0" {
            Outbrain.lastTParam = nil
            Outbrain.lastApvParam = nil
        }
        
        Outbrain.logger.debug("fetch recs - got response", domain: "request-handler")
        // a mocked response with error to return in case of
        var responseWithError = OBRecommendationResponse(request: [:], settings: [:], viewabilityActions: nil, recommendations: [], error: nil)
        
        // Request Error
        if let error = error {
            responseWithError.error = OBError.networkError(message: "\(error.localizedDescription)", key: .networkError, code: .genericErrorCode)
            Outbrain.logger.error("fetch recs - network error: \(error.localizedDescription)", domain: "request-handler")
            OBErrorReport.shared.errorMessage = "fetch recs - network error: \(error.localizedDescription)"
            try callback(responseWithError)
            return
        }
        
        // HTTP Invalid Error
        guard let httpResponse = response as? HTTPURLResponse else {
            responseWithError.error = OBError.networkError(message: "Invalid HTTP Response", key: .networkError, code: .genericErrorCode)
            Outbrain.logger.error("fetch recs - invalid HTTP Response: \(String(describing: response))", domain: "request-handler")
            OBErrorReport.shared.errorMessage = "fetch recs - invalid HTTP Response: \(String(describing: response))"
            try callback(responseWithError)
            return
        }
        
        // Check for response code errors
        if let errorResponse = handleHttpErrorResponseCode(for: httpResponse.statusCode) {
            responseWithError.error = errorResponse
            Outbrain.logger.error("fetch recs - HTTP error: \(httpResponse.statusCode)", domain: "request-handler")
            OBErrorReport.shared.errorMessage = "fetch recs - HTTP error: \(httpResponse.statusCode)"
            try callback(responseWithError)
            return
        }
        
        // No Data Error
        guard let jsonData = data else {
            responseWithError.error = OBError.networkError(message: "No data received", key: .networkError, code: .noDataErrorCode)
            Outbrain.logger.error("fetch recs - no data received", domain: "request-handler")
            OBErrorReport.shared.errorMessage = "fetch recs - no data received"
            try callback(responseWithError)
            return
        }
        
        // JSON Parsing Error
        guard var response = parseJsonData(with: jsonData) else {
            responseWithError.error = OBError.nativeError(message: "Parsing failed", key: .nativeError, code: .parsingErrorCode)
            Outbrain.logger.error("fetch recs - parsing failed", domain: "request-handler")
            OBErrorReport.shared.errorMessage = "fetch recs - parsing failed"
            try callback(responseWithError)
            return
        }
        
        // Error reporting poplate details in case of later one error
        if let pid = response.request["pid"] as? String {
            OBErrorReport.shared.publisherId = pid
        }
        if let sid = response.request["sid"] as? Int {
            OBErrorReport.shared.sourceId = String(sid)
        }
                
        // no recs error
        if response.recommendations.isEmpty {
            response.error = OBError.zeroRecommendationsError(message: "No recs", key: .zeroRecommendationsError, code: .noRecommendationsErrorCode)
            Outbrain.logger.error("fetch recs - no recs", domain: "request-handler")
        }
        
        Outbrain.logger.log("fetch recs - done, response: \(response)", domain: "request-handler")
        
        // enable global statistics by setting
        OBGlobalStatisticsManager.shared.checkAndUpdateGlobalStatisticsSetting(response)
        
        // fire served pixel
        if OBGlobalStatisticsManager.shared.isGlobalStatsticsEnabled() {
            OBGlobalStatisticsManager.shared.reportServed(request: self.request, response: response, timestamp: self.request.startDate!)
        }
        
        // fire pixels
        OBGlobalStatisticsManager.shared.firePixels(for: response)
        
        // invoke callback with parsed recs
        try callback(response)
    }
    
    func handleHttpErrorResponseCode(for statusCode: Int) -> OBError? {
        if (400..<500).contains(statusCode) {
            return OBError.networkError(message: "Client Error \(statusCode)", key: .networkError, code: .invalidParametersErrorCode)
        } else if (500..<600).contains(statusCode) {
            return OBError.networkError(message: "Server Error \(statusCode)", key: .networkError, code: .serverErrorCode)
        }
        
        return nil
    }
    
    // MARK: JSON Parsing - parsing respose from odb to a valid OBResponse struct
    
    // parse JSON response
    func parseJsonData(with jsonData: Data) -> OBRecommendationResponse? {
        do {
            let json = try JSONSerialization.jsonObject(with: jsonData)
            
            // checking that we got the right dicts
            guard let jsonDict = json as? [String: Any],
                  let responseDict = jsonDict["response"] as? [String: Any],
                  let request = responseDict["request"] as? [String: Any],
                  let settings = responseDict["settings"] as? [String: Any],
                  let va = responseDict["viewability_actions"] as? [String: Any] else {
                return nil
            }
            
            //request id
            let reqId = request["req_id"] as! String?
            
            // parse docs into recs
            var recs: [OBRecommendation] = []
            if let documents = responseDict["documents"] as? [String: Any],
               let docs = documents["doc"] as? [[String: Any]] {
                recs = parseDocs(docs: docs, reqId: reqId)
            }
            
            // parse viewability actions
            let viewabilityActions = parseViewabilityActions(from: va)
                        
            // store t param
            if let tParam = request["t"] as? String, self.request.idx == "0" {
                Outbrain.lastTParam = tParam
                Outbrain.logger.debug("got T param: \(tParam)", domain: "request-handler")
            }
            
            // store apv param, only keep for future requests
            if let apvParam = settings["apv"] as? Bool,
               apvParam == true {
                Outbrain.lastApvParam = apvParam
                Outbrain.logger.debug("got apv param: \(apvParam)", domain: "request-handler")
            }
                        
            // build final response object
            return OBRecommendationResponse(request: request, settings: settings, viewabilityActions: viewabilityActions, recommendations: recs, error: nil)
        } catch {
            Outbrain.logger.error("Error parsing JSON: \(error.localizedDescription)", domain: "request-handler")
            return nil
        }
    }

    // parse documents dicts into recs
    func parseDocs(docs: [[String: Any]], reqId: String?) -> [OBRecommendation] {
        var recs: [OBRecommendation] = []
        
        guard let reqId = reqId else {
            return recs
        }
        
        // iterate over docs and build recs objects
        for doc in docs {
            var rec = OBRecommendation()
            
            // extract main rec props
            extractValidProps(from: doc, into: &rec)
            
            // extract publish date
            extractPublishDate(from: doc, into: &rec)
            
            // extract rec image
            extractRecImage(from: doc, into: &rec)
            
            // extract disclosure
            extractDisclosure(from: doc, into: &rec)
            
            // inject request id for later use
            rec.reqId = reqId
            
            // append new rec
            recs.append(rec)
        }
        
        return recs
    }

    func extractValidProps(from doc: [String: Any], into rec: inout OBRecommendation) {
        if let url = doc["url"] as? String {
            rec.url = url
        }
        
        if let origUrl = doc["orig_url"] as? String {
            rec.origUrl = origUrl
        }
        
        if let content = doc["content"] as? String {
            rec.content = content
        }
        
        if let source = doc["source_name"] as? String {
            rec.source = source
        }
        
        if let position = doc["pos"] as? String {
            rec.position = position
        }
        
        if let author = doc["author"] as? String {
            rec.author = author
        }
        
        if let sameSource = doc["same_source"] as? String {
            rec.sameSource = sameSource == "true"
        }
        
        if let pixels = doc["pixels"] as? [String] {
            rec.pixels = pixels
        }
    }

    func extractPublishDate(from doc: [String: Any], into rec: inout OBRecommendation) {
        if let publishDate = doc["publish_date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            if let date = dateFormatter.date(from: publishDate) {
                rec.publishDate = date
            }
        }
    }

    func extractRecImage(from doc: [String: Any], into rec: inout OBRecommendation) {
        if let imageUrlDict = doc["thumbnail"] as? [String: Any],
           let imageUrl = imageUrlDict["url"] as? String,
           let imageHeight = imageUrlDict["height"] as? Int,
           let imageWidth = imageUrlDict["width"] as? Int {
            rec.image = OBImageInfo(width: imageWidth, height: imageHeight, url: URL(string: imageUrl))
        }
    }

    func extractDisclosure(from doc: [String: Any], into rec: inout OBRecommendation) {
        if let disclosureDict = doc["disclosure"] as? [String: Any],
           let imageUrl = disclosureDict["icon"] as? String,
           let clickUrl = disclosureDict["url"] as? String {
            rec.disclosure = OBDisclosure(imageUrl: imageUrl, clickUrl: clickUrl)
        }
    }
    
    func parseViewabilityActions(from va: [String: Any] ) -> OBViewabilityActions? {
        let reportServed = va["reportServed"] as? String
        let reportViewed = va["reportViewed"] as? String
        return OBViewabilityActions(reportServed: reportServed, reportViewed: reportViewed)
    }
    
    // MARK: Params Enrichment - build the request query params based on OBRequest
    
    // odb request url builder
    func buildOdbParams() -> URL? {
        var reqUrl = URLComponents(string: isPlatformsRequest ? OB_REQUEST_HANDLER_CONSTANTS.PLATFORMS_BASE_URL : OB_REQUEST_HANDLER_CONSTANTS.ODB_BASE_URL)!
        
        // query params
        var queryItems = [
            addReqParam(name: "key", value: Outbrain.partnerKey),
            addReqParam(name: "version", value: Outbrain.OB_SDK_VERSION),
            addReqParam(name: "app_ver", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""),
            addReqParam(name: "rand", value: String(describing: Int.random(in: 0..<10000))),
            addReqParam(name: "widgetJSId", value: self.request.widgetId),
            addReqParam(name: "idx", value: self.request.idx),
            addReqParam(name: "format", value: "vjnc"),
            addReqParam(name: "api_user_id", value: OBRequestHandler.getApiUserId()),
            addReqParam(name: "installationType", value: "ios_sdk"),
            addReqParam(name: "rtbEnabled", value: "true"),
            addReqParam(name: "sk_network_version", value: OBRequestHandler.getSkNetworkVersion()),
            addReqParam(name: "app_id", value: Bundle.main.bundleIdentifier),
            addReqParam(name: "doo", value: OBRequestHandler.getOptedOut() ? "true" : "false"),
            addReqParam(name: "dos", value: "ios"),
            addReqParam(name: "platform", value: "ios"),
            addReqParam(name: "dosv", value: UIDevice.current.systemVersion),
            addReqParam(name: "dm", value: DeviceModelUtils.deviceModel),
            addReqParam(name: "deviceType", value: DeviceModelUtils.deviceTypeShort),
            addReqParam(name: "va", value: "true"),
            addReqParam(name: "t", value: getTParam()),
            addReqParam(name: "apv", value: getApvParam()),
            addReqParam(name: "secured", value: "true"),
            addReqParam(name: "ref", value: "https://app-sdk.outbrain.com/"),
            addReqParam(name: "extid", value: self.request.externalID),
            addReqParam(name: "cnsnt", value: GDPRUtils.gdprV1ConsentString ?? ""),
            addReqParam(name: "cnsntv2", value: GDPRUtils.gdprV2ConsentString ?? ""),
            addReqParam(name: "ccpa", value: GDPRUtils.ccpaPrivacyString ?? ""),
            addReqParam(name: "gpp_sid", value: GPPUtils.gppSections ?? ""),
            addReqParam(name: "gpp", value: GPPUtils.gppString ?? ""),
        ]
        
        // add platforms params if needed or just the url if regular call
        if isPlatformsRequest {
            self.addPlatformsQueryParams(for: &queryItems)
        } else {
            queryItems.append(addReqParam(name: "url", value: self.request.url))
        }
        
        // add test mode
        if Outbrain.setTestMode {
            queryItems.append(addReqParam(name: "testMode", value: "true"))
            
            if Outbrain.testRTB {
                queryItems.append(URLQueryItem(name: "fakeRec", value: "RTB"))
                queryItems.append(URLQueryItem(name: "fakeRecSize", value: "2"))
                queryItems.append(URLQueryItem(name: "rtbEnabled", value: "true"))
            }
            
            if Outbrain.testLocation != nil {
                queryItems.append(URLQueryItem(name: "location", value: Outbrain.testLocation))
            }
        }
        
        // filter out invliad params
        reqUrl.queryItems = queryItems.compactMap { $0 }
        
        return reqUrl.url
    }
    
    // add param to request, if invalid/empty string will return nill
    func addReqParam(name: String, value: String?) -> URLQueryItem? {
        if value == nil || value!.isEmpty {
            return nil
        }
        return URLQueryItem(name: name, value: value!)
    }
    
    // platforms request, add the relevant params
    func addPlatformsQueryParams(for queryItems: inout [URLQueryItem?]) {
        guard let platformsRequest = self.request as? OBPlatformsRequest else {
            return
        }
         
        // check if using bundle or portal url
        if platformsRequest.isUsingBundleUrl || platformsRequest.isUsingPortalUrl {
            // check that lang exists
            guard let lang = platformsRequest.lang else {
                Outbrain.logger.error("lang is mandatory when using platforms request")
                // should we throw an error here?
                return
            }
            
            // determine which param to add
            let parmKey = platformsRequest.isUsingBundleUrl ? "bundleUrl" : "portalUrl"
            let paramVal = platformsRequest.isUsingBundleUrl ? platformsRequest.bundleUrl : platformsRequest.portalUrl
            
            // add param
            queryItems.append(addReqParam(name: parmKey, value: paramVal)!)
            
            // add lang param
            queryItems.append(addReqParam(name: "lang", value: lang)!)
        } else if platformsRequest.isUsingContentUrl {
            queryItems.append(addReqParam(name: "contentUrl", value: platformsRequest.contentUrl)!)
        }
        
        // add psub param if exists
        if let psub = platformsRequest.psub {
            queryItems.append(addReqParam(name: "psub", value: psub)!)
        }
    }
    
    // populate api_user_id from OS if the user is not opted out or customerId declared
    static func getApiUserId() -> String {
        var apiUserId: String

        if OBAppleAdIdUtil.isOptedOut {
            apiUserId = "null"
        } else {
            apiUserId = OBAppleAdIdUtil.advertiserId
        }

        if let customUserId = Outbrain.customUserId {
            apiUserId = customUserId
        }
        
        return apiUserId
    }
    
    // populate sk_network_version
    static func getSkNetworkVersion() -> String {
        if #available(iOS 14, *) {
            return "2.0"
        }
        return "1.0"
    }
    
    // populate doo - based on OS
    static func getOptedOut() -> Bool {
        return OBAppleAdIdUtil.isOptedOut
    }
    
    // populate t param from previous req
    func getTParam() -> String? {
        // if it's the first widget on page, no t param yet
        if self.request.idx == "0" {
            return nil
        }

        // check that we have the t param from last idx 0 call
        guard let tParam = Outbrain.lastTParam else {
            return nil
        }
        
        // return the stored t param
        return tParam
    }
    
    // populate apv param from previous req
    func getApvParam() -> String? {
        // check that we have the apv param from last idx 0 call
        guard let apvParam = Outbrain.lastApvParam else {
            return nil
        }
        
        // return the stored apv param
        return apvParam ? "true" : nil
    }
    
}

enum OB_REQUEST_HANDLER_CONSTANTS {
    static let ODB_BASE_URL = "https://odb.outbrain.com/utils/get/"
    static let PLATFORMS_BASE_URL = "https://odb.outbrain.com/utils/platforms/"
}
