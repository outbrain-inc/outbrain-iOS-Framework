//
//  OBRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

@objc public class OBRequest: NSObject {
    
    @objc public var url: String? // url to fetch the recommendations
    @objc public var widgetId: String // widget id
    @objc public var widgetIndex: Int // widget index
    @objc public var externalID: String? // external id
    @objc public var startDate: Date? // start date
    
    @objc public init(
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
    
    @objc public static func requestWithURL(_ url: String?, widgetID: String) -> OBRequest {
        return OBRequest(url: url, widgetID: widgetID)
    }
    
    @objc public static func requestWithURL(_ url: String?, widgetID: String, widgetIndex: Int) -> OBRequest {
        return OBRequest(url: url, widgetID: widgetID, widgetIndex: widgetIndex)
    }
}
