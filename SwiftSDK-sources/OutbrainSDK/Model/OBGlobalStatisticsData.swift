//
//  OBViewabilityData.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 27/06/2023.
//

import Foundation

public struct OBGlobalStatisticsData {
    var reportServedUrl: String? // report served url
    var reportViewedUrl: String? // report viewed url
    var rId: String? // request id
    var requestStartDate: Date? // request start date
    var optedOut: Bool? // opted out
    
    init(reportServedUrl: String? = nil, reportViewedUrl: String? = nil, rId: String? = nil, requestStartDate: Date? = nil, optedOut: Bool? = nil) {
        self.reportServedUrl = reportServedUrl
        self.reportViewedUrl = reportViewedUrl
        self.rId = rId
        self.requestStartDate = requestStartDate
        self.optedOut = optedOut
    }
}
