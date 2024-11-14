//
//  OBPlatformRequestUrlBuilder.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 11/11/2024.
//


struct OBPlatformRequestUrlBuilder: OBRequestUrlBuilderProtocol {
    
    var request: OBRequest { platformRequest }
    let platformRequest: OBPlatformRequest
    let urls: OBRequestURLProtocol
    
    
    init(platformRequest: OBPlatformRequest) {
        self.platformRequest = platformRequest
        self.urls = OBPlatformRequestURLs()
    }
    
    
    func buildOdbParams() -> URLComponents? {
        var queryItems = buildDefaultQueryItems()
        
        
        if platformRequest.bundleUrl == nil && platformRequest.portalUrl == nil && platformRequest.contentUrl == nil {
            Outbrain.logger.error("bundleUrl, portalUrl or contentUrl are mandatory when using platforms request")
            return nil
        }
        
        if platformRequest.isUsingBundleUrl || platformRequest.isUsingPortalUrl {
            guard let lang = platformRequest.lang else {
                Outbrain.logger.error("lang is mandatory when using platforms request")
                return nil
            }
            
            let parmKey = platformRequest.isUsingBundleUrl ? "bundleUrl" : "portalUrl"
            let paramVal = platformRequest.isUsingBundleUrl ? platformRequest.bundleUrl : platformRequest.portalUrl
            
            queryItems.append(addReqParam(name: parmKey, value: paramVal)!)
            queryItems.append(addReqParam(name: "lang", value: lang)!)
        } else if platformRequest.isUsingContentUrl {
            queryItems.append(addReqParam(name: "contentUrl", value: platformRequest.contentUrl)!)
        }
        
        
        if let psub = platformRequest.psub {
            queryItems.append(addReqParam(name: "psub", value: psub)!)
        }
        
        
        var reqComponents = urls.toComponents()
        reqComponents.queryItems = queryItems.compactMap { $0 }
        return reqComponents
    }
}
