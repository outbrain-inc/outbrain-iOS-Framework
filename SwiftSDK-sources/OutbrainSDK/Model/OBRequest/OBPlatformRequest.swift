//
//  OBPlatformsRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 22/06/2023.
//

import Foundation

@objc public class OBPlatformRequest: OBRequest {
    
    @objc public var contentUrl: String?
    @objc public var portalUrl: String?
    @objc public var bundleUrl: String?
    @objc public var lang: String?
    @objc public var psub: String?
    
    
    var isValid: Bool {
        return (contentUrl != nil || portalUrl != nil) && lang != nil
    }
    
    var isUsingContentUrl: Bool {
        return contentUrl != nil
    }
    
    var isUsingPortalUrl: Bool {
        return portalUrl != nil
    }
    
    var isUsingBundleUrl: Bool {
        return bundleUrl != nil
    }
    
    
    public init(
        widgetID: String,
        widgetIndex: Int = 0,
        contentUrl: String? = nil,
        portalUrl: String? = nil,
        bundleUrl: String? = nil,
        lang: String? = nil,
        psub: String? = nil
    ) {
        super.init(url: nil, widgetID: widgetID, widgetIndex: widgetIndex)
        self.contentUrl = contentUrl
        self.portalUrl = portalUrl
        self.bundleUrl = bundleUrl
        self.lang = lang
        self.psub = psub
        self.urls = OBPlatformRequestURLs()
    }
    
    
    // Objective-C compatible factory method for `requestWithBundleURL:lang:widgetID:`
    @objc public static func requestWithBundleURL(_ bundleUrl: String, lang: String, widgetID: String) -> OBPlatformRequest {
        return OBPlatformRequest(
            widgetID: widgetID,
            bundleUrl: bundleUrl,
            lang: lang
        )
    }

    // Objective-C compatible factory method for `requestWithPortalURL:lang:widgetID:`
    @objc public static func requestWithPortalURL(_ portalUrl: String, lang: String, widgetID: String) -> OBPlatformRequest {
        return OBPlatformRequest(
            widgetID: widgetID,
            portalUrl: portalUrl,
            lang: lang
        )
    }
    
    
    override func buildOdbParams() -> URLComponents? {
        let urlComponents = super.buildOdbParams()
        var queryItems = urlComponents?.queryItems ?? []
        
        if isUsingBundleUrl || isUsingPortalUrl {
            guard let lang = lang else {
                Outbrain.logger.error("lang is mandatory when using platforms request")
                return nil
            }
            
            let parmKey = isUsingBundleUrl ? "bundleUrl" : "portalUrl"
            let paramVal = isUsingBundleUrl ? bundleUrl : portalUrl
            
            queryItems.append(addReqParam(name: parmKey, value: paramVal)!)
            queryItems.append(addReqParam(name: "lang", value: lang)!)
        } else if isUsingContentUrl {
            queryItems.append(addReqParam(name: "contentUrl", value: contentUrl)!)
        }
    
        
        if let psub = psub {
            queryItems.append(addReqParam(name: "psub", value: psub)!)
        }
        
        return urlComponents
    }
}
