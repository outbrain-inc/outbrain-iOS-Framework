//
//  OBPlatformsRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 22/06/2023.
//

import Foundation

public class OBPlatformsRequest: OBRequest {
    public var contentUrl: String? // content url
    public var portalUrl: String? // portal url
    public var bundleUrl: String? // bundle url
    public var lang: String? // language
    public var psub: String? // psub
    
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
    
    public init(widgetID: String, widgetIndex: Int = 0, contentUrl: String? = nil, portalUrl: String? = nil, budnelUrl: String? = nil, lang: String? = nil, psub: String? = nil) {
        super.init(url: nil, widgetID: widgetID, widgetIndex: widgetIndex)
        self.contentUrl = contentUrl
        self.portalUrl = portalUrl
        self.bundleUrl = budnelUrl
        self.lang = lang
        self.psub = psub
    }
}
