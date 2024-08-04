//
//  OBAppleAdIdUtil.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 20/06/2023.
//

import Foundation
import AdSupport
import AppTrackingTransparency

class OBAppleAdIdUtil {
    
    // check if user has opted out of tracking
    static var isOptedOut: Bool {
        if Outbrain.testMode { return false }
        
        return ATTrackingManager.trackingAuthorizationStatus != .authorized
    }

    
    // get the apple advertising id
    static var advertiserId: String {
        if Outbrain.testMode {
            return "F22700D5-1D49-42CC-A183-F3676526035F" // dev hack because simulator returns 0000-0000-0000-0000
        }
        
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        
        guard !idfa.isEmpty else { return "null" }
        return idfa
    }
}
