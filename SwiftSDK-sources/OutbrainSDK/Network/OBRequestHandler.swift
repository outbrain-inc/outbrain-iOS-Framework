//
//  OBRequestHandler.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation


public struct OBRequestHandler {
    
    private let request: OBRequest
    private let requestUrlBuilder: OBRequestUrlBuilderProtocol
    
    
    init(_ request: OBRequest) {
        self.request = request
        
        if let platformRequest = request as? OBPlatformRequest {
            requestUrlBuilder = OBPlatformRequestUrlBuilder(platformRequest: platformRequest)
        } else {
            requestUrlBuilder = OBRequestUrlBuilder(request: request)
        }
    }
    
    
    // MARK: Fetch Recomendations - make http request for fetching recommendations from odb, option to pass callback or delegate that will resolve to OBResponse
    func fetchRecs(callback: @escaping (OBRecommendationResponse) -> Void) {
        guard requestUrlBuilder.buildOdbParams() != nil else { return }
        
        Task {
            do {
                let recs = try await fetchRecsAsync()
                callback(recs)
            } catch {
                callback(.init(
                    request: [:],
                    settings: [:],
                    viewabilityActions: nil,
                    recommendations: [],
                    error: error as? OBError)
                )
            }
        }
    }
    
    
    func fetchRecs(delegate: OBResponseDelegate) {
        guard requestUrlBuilder.buildOdbParams() != nil else { return }
        Task {
            do {
                let recs = try await fetchRecsAsync()
                delegate.outbrainDidReceiveResponse(withSuccess: recs)
            } catch {
                delegate.outbrainFailedToReceiveResposne(withError: error as? OBError)
            }
        }
    }
    
    
    func fetchRecsAsync() async throws -> OBRecommendationResponse {
        guard let url = requestUrlBuilder.buildOdbParams()?.url else {
            throw OBError.native(message: "Failed to build ODB URL", code: .invalidParameters)
        }
        
        defer {
            if OBErrorReport.shared.errorMessage != nil {
                OBErrorReport.shared.reportErrorToServer()
            }
        }
        
        Outbrain.logger.debug("fetch recs async - started fetch", domain: "request-handler")
        
        // init error reporting data
        OBErrorReport.shared.resetReport()
        OBErrorReport.shared.odbRequestUrlParamValue = request.url
        OBErrorReport.shared.widgetId = request.widgetId
        
        request.startDate = Date()
        Outbrain.logger.log("fetch recs - async fetch started for url \(url.absoluteString)", domain: "request-handler")
        
        
        var urlRequest = URLRequest(url: url)
        
#if DEBUG
        urlRequest.setValue("true", forHTTPHeaderField: "x-trace")
#endif
        
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
#if DEBUG
            if let debugRes = response as? HTTPURLResponse {
                if let traceID = debugRes.value(forHTTPHeaderField: "x-traceid") {
                    // Access the trace ID here
                    Outbrain.logger.debug("fetch recs async - trace id: \(traceID)", domain: "request-handler")
                }
            }
#endif
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let errorMessage = "fetch recs async - invalid HTTP Response: \(String(describing: response))"
                Outbrain.logger.error(errorMessage, domain: "request-handler")
                OBErrorReport.shared.errorMessage = errorMessage
                throw OBError.network(message: errorMessage, code: .generic)
            }
            

            if let responseCodeError = handleHttpErrorResponseCode(for: httpResponse.statusCode) {
                let errorMessage = "fetch recs async - HTTP error: \(httpResponse.statusCode)"
                Outbrain.logger.error(errorMessage, domain: "request-handler")
                OBErrorReport.shared.errorMessage = errorMessage
                throw responseCodeError
            }
            
            
            guard !data.isEmpty else {
                let error = OBError.zeroRecommendations(
                    message: "No data received",
                    code: .noData
                )
                
                Outbrain.logger.error(
                    "fetch recs async - no data received",
                    domain: "request-handler"
                )
                
                OBErrorReport.shared.errorMessage = "fetch recs async - no data received"
                throw error
            }
            
            
            // JSON Parsing Error
            guard let response = parseJsonData(with: data) else {
                let error = OBError.native(
                    message: "Parsing failed",
                    code: .parsing
                )
                
                let errorMessage = "fetch recs async - parsing failed"
                Outbrain.logger.error(errorMessage, domain: "request-handler")
                OBErrorReport.shared.errorMessage = errorMessage
                throw error
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
                response.error = OBError.zeroRecommendations(
                    message: "No recs",
                    code: .noRecommendations
                )
                
                Outbrain.logger.error("fetch recs - no recs", domain: "request-handler")
            }
            
            Outbrain.logger.log("fetch recs - done, response: \(response)", domain: "request-handler")
            
            OBGlobalStatisticsManager.shared.checkAndUpdateGlobalStatisticsSetting(response)
            
            if OBGlobalStatisticsManager.shared.isGlobalStatsticsEnabled() {
                OBGlobalStatisticsManager.shared.reportServed(request: request,
                                                              response: response,
                                                              timestamp: request.startDate ?? Date()
                )
            }
            
            OBGlobalStatisticsManager.shared.firePixels(for: response)
            return response
        } catch {
            Outbrain.logger.error(
                "fetch recs async - network error: \(error.localizedDescription)",
                domain: "request-handler"
            )
            
            OBErrorReport.shared.errorMessage = "fetch recs async - network error: \(error.localizedDescription)"
            
            if error is OBError {
                throw error
            } else {
                throw OBError.network(message: "fetch recs async - network error: \(error.localizedDescription)", code: .network)
            }
        }
    }
    
    
    // MARK: Handle Response - checks if got valid response back from the server
    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?) throws -> OBRecommendationResponse {
        // report error to widget monitor if error
        defer {
            if OBErrorReport.shared.errorMessage != nil {
                OBErrorReport.shared.reportErrorToServer()
            }
        }
        
        // reset t & apv params
        if request.widgetIndex == 0 {
            Outbrain.lastTParam = nil
            Outbrain.lastApvParam = nil
        }
        
        Outbrain.logger.debug("fetch recs - got response", domain: "request-handler")
        // a mocked response with error to return in case of
        let responseWithError = OBRecommendationResponse(request: [:], settings: [:], viewabilityActions: nil, recommendations: [], error: nil)
        
        // Request Error
        if let error = error {
            responseWithError.error = OBError.network(
                message: error.localizedDescription,
                code: .generic
            )
            
            Outbrain.logger.error(
                "fetch recs - network error: \(error.localizedDescription)",
                domain: "request-handler"
            )
            
            OBErrorReport.shared.errorMessage = "fetch recs - network error: \(error.localizedDescription)"
            return responseWithError
        }
        
        // HTTP Invalid Error
        guard let httpResponse = response as? HTTPURLResponse else {
            responseWithError.error = OBError.network(
                message: "Invalid HTTP Response",
                code: .generic
            )
            
            Outbrain.logger.error(
                "fetch recs - invalid HTTP Response: \(String(describing: response))",
                domain: "request-handler"
            )
            
            OBErrorReport.shared.errorMessage = "fetch recs - invalid HTTP Response: \(String(describing: response))"
            return responseWithError
        }
        
        // Check for response code errors
        if let errorResponse = handleHttpErrorResponseCode(for: httpResponse.statusCode) {
            responseWithError.error = errorResponse
            Outbrain.logger.error(
                "fetch recs - HTTP error: \(httpResponse.statusCode)",
                domain: "request-handler"
            )
            
            OBErrorReport.shared.errorMessage = "fetch recs - HTTP error: \(httpResponse.statusCode)"
            return responseWithError
        }
        
        // No Data Error
        guard let jsonData = data else {
            responseWithError.error = OBError.network(
                message: "No data received",
                code: .noData
            )
            
            Outbrain.logger.error(
                "fetch recs - no data received",
                domain: "request-handler"
            )
            
            OBErrorReport.shared.errorMessage = "fetch recs - no data received"
            return responseWithError
        }
        
        // JSON Parsing Error
        guard let response = parseJsonData(with: jsonData) else {
            responseWithError.error = OBError.native(
                message: "Parsing failed",
                code: .parsing
            )
            
            Outbrain.logger.error("fetch recs - parsing failed", domain: "request-handler")
            OBErrorReport.shared.errorMessage = "fetch recs - parsing failed"
            return responseWithError
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
            response.error = OBError.zeroRecommendations(
                message: "No recs",
                code: .noRecommendations
            )
            
            Outbrain.logger.error("fetch recs - no recs", domain: "request-handler")
        }
        
        Outbrain.logger.log("fetch recs - done, response: \(response)", domain: "request-handler")
        
        // enable global statistics by setting
        OBGlobalStatisticsManager.shared.checkAndUpdateGlobalStatisticsSetting(response)
        
        // fire served pixel
        if OBGlobalStatisticsManager.shared.isGlobalStatsticsEnabled() {
            OBGlobalStatisticsManager.shared.reportServed(request: request,
                                                          response: response,
                                                          timestamp: request.startDate ?? Date()
            )
        }
        
        // fire pixels
        OBGlobalStatisticsManager.shared.firePixels(for: response)
        
        // invoke callback with parsed recs
        return response
    }
    
    
    func handleHttpErrorResponseCode(for statusCode: Int) -> OBError? {
        if (400..<500).contains(statusCode) {
            return OBError.network(
                message: "Client Error \(statusCode)",
                code: .invalidParameters
            )
        } else if (500..<600).contains(statusCode) {
            return OBError.network(
                message: "Server Error \(statusCode)",
                code: .server
            )
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
            let reqId = request["req_id"] as? String
            
            // parse docs into recs
            var recs: [OBRecommendation] = []
            if let documents = responseDict["documents"] as? [String: Any],
               let docs = documents["doc"] as? [[String: Any]] {
                recs = parseDocs(docs: docs, reqId: reqId)
            }
            
            // parse viewability actions
            let viewabilityActions = parseViewabilityActions(from: va)
            
            // store t param
            if let tParam = request["t"] as? String, self.request.widgetIndex == 0 {
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
            return OBRecommendationResponse(
                request: request,
                settings: settings,
                viewabilityActions: viewabilityActions,
                recommendations: recs,
                error: nil
            )
        } catch {
            Outbrain.logger.error(
                "Error parsing JSON: \(error.localizedDescription)",
                domain: "request-handler"
            )
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
        rec.url = doc["url"] as? String
        rec.origUrl = doc["orig_url"] as? String
        rec.content = doc["content"] as? String
        rec.source = doc["source_name"] as? String
        rec.position = doc["pos"] as? String
        rec.author = doc["author"] as? String
        rec.sameSource = doc["same_source"] as? String == "true"
        rec.pixels = doc["pixels"] as? [String]
    }
    
    
    func extractPublishDate(from doc: [String: Any], into rec: inout OBRecommendation) {
        guard let publishDate = doc["publish_date"] as? String else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        if let date = dateFormatter.date(from: publishDate) {
            rec.publishDate = date
        }
    }
    
    
    func extractRecImage(from doc: [String: Any], into rec: inout OBRecommendation) {
        guard let imageUrlDict = doc["thumbnail"] as? [String: Any],
              let imageUrl = imageUrlDict["url"] as? String,
              let imageHeight = imageUrlDict["height"] as? Int,
              let imageWidth = imageUrlDict["width"] as? Int else { return }
        rec.image = OBImageInfo(width: imageWidth, height: imageHeight, url: URL(string: imageUrl))
    }
    
    
    func extractDisclosure(from doc: [String: Any], into rec: inout OBRecommendation) {
        guard let disclosureDict = doc["disclosure"] as? [String: Any],
              let imageUrl = disclosureDict["icon"] as? String,
              let clickUrl = disclosureDict["url"] as? String else { return }
        rec.disclosure = OBDisclosure(imageUrl: imageUrl, clickUrl: clickUrl)
    }
    
    
    func parseViewabilityActions(from va: [String: Any] ) -> OBViewabilityActions? {
        return OBViewabilityActions(reportServed: va["reportServed"] as? String, reportViewed: va["reportViewed"] as? String)
    }
    
    
    // MARK: Params Enrichment - build the request query params based on OBRequest

    // add param to request, if invalid/empty string will return nill
    
    
    
    
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
}
