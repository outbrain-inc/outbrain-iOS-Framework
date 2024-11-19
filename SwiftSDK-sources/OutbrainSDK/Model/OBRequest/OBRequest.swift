//
//  OBRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation
import UIKit


@objcMembers public class OBRequest: NSObject {
    
    public var url: String? // url to fetch the recommendations
    public var widgetId: String // widget id
    public var widgetIndex: Int // widget index
    public var externalID: String? // external id
    public var startDate: Date? // start date
    
    var isPlatformsRequest: Bool {
        return (self as? OBPlatformRequest) != nil
    }
    

    public init(
        url: String?,
        widgetID: String,
        widgetIndex: Int = 0,
        externalID: String? = nil,
        startDate: Date? = nil
    ) {
        self.url = url
        self.widgetId = widgetID
        self.widgetIndex = widgetIndex
        self.externalID = externalID
        self.startDate = startDate
    }
    
    public static func requestWithURL(_ url: String?, widgetID: String) -> OBRequest {
        return OBRequest(url: url, widgetID: widgetID)
    }
    
    public static func requestWithURL(_ url: String?, widgetID: String, widgetIndex: Int) -> OBRequest {
        return OBRequest(url: url, widgetID: widgetID, widgetIndex: widgetIndex)
    }
}

