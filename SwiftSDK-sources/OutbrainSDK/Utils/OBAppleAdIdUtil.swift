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
        if #available(iOS 14.0, *) {
            return ATTrackingManager.trackingAuthorizationStatus != .authorized
        } else {
            return !ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        }
    }

    // get the apple advertising id
    static var advertiserId: String {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if !idfa.isEmpty {
            return idfa
        }
        return "null"
    }
}
