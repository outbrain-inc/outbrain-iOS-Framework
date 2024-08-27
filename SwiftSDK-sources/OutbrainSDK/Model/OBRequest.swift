//
//  OBRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

public class OBRequest {
    
    public var url: String? // url to fetch the recommendations
    public var widgetId: String // widget id
    public var idx: String? // widget index
    public var externalID: String? // external id
    public var startDate: Date? // start date
    
    public init(
        url: String?,
        widgetID: String,
        widgetIndex: Int = 0,
        externalID: String? = nil,
        startDate: Date? = nil
    ) {
        self.url = url
        self.widgetId = widgetID
        self.idx = "\(widgetIndex)"
        self.externalID = externalID
        self.startDate = startDate
    }
}
