//
//  OBViewabilityActions.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 28/06/2023.
//

import Foundation

@objc public class OBViewabilityActions: NSObject {
    
    let reportServed: String?
    let reportViewed: String?
    
    init(reportServed: String?, reportViewed: String?) {
        self.reportServed = reportServed
        self.reportViewed = reportViewed
    }
}
