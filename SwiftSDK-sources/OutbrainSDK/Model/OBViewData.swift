//
//  OBViewData.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 04/07/2023.
//

import Foundation

public struct OBViewData {
    
    var positions: [String]?
    var requestId: String?
    var initializationTime: Date?
    
    init(
        positions: [String]? = nil,
        requestId: String? = nil,
        initializationTime: Date? = nil
    ) {
        self.positions = positions
        self.requestId = requestId
        self.initializationTime = initializationTime
    }
}
