//
//  OBRequest.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

public class OBRequest {
    var url: String? // url to fetch the recommendations
    var widgetId: String // widget id
    var idx: String? // widget index
    var externalID: String? // external id
    var startDate: Date? // start date
    
    public init(url: String?, widgetID: String, widgetIndex: String = "0", externalID: String? = nil, startDate: Date? = nil) {
        self.url = url
        self.widgetId = widgetID
        self.idx = widgetIndex
        self.externalID = externalID
        self.startDate = startDate
    }
}
