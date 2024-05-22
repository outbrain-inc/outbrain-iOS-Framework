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
        if Outbrain.setTestMode { return false }
        
        if #available(iOS 14.0, *) {
            return ATTrackingManager.trackingAuthorizationStatus != .authorized
        } else {
            return !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
    }

    // get the apple advertising id
    static var advertiserId: String {
        if Outbrain.setTestMode {
            return "F22700D5-1D49-42CC-A183-F3676526035F" // dev hack because simulator returns 0000-0000-0000-0000
        }
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if !idfa.isEmpty {
            return idfa
        }
        return "null"
    }
}
