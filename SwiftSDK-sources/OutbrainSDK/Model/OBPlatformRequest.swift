//
//  OBPlatformsRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 22/06/2023.
//

import Foundation

@objc public class OBPlatformRequest: OBRequest {
    
    @objc public var contentUrl: String? // content url
    @objc public var portalUrl: String? // portal url
    @objc public var bundleUrl: String? // bundle url
    @objc public var lang: String? // language
    @objc public var psub: String? // psub
    
    // check if the request is valid
    var isValid: Bool {
        return (contentUrl != nil || portalUrl != nil) && lang != nil
    }
    
    // check if using content url
    var isUsingContentUrl: Bool {
        return contentUrl != nil
    }
    
    // check if using portal url
    var isUsingPortalUrl: Bool {
        return portalUrl != nil
    }
    
    // check if using bundle url
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
}
