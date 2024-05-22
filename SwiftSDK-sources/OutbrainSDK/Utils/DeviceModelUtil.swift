//
//  DeviceModelUtil.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 20/06/2023.
//

import Foundation
import UIKit

class DeviceModelUtils {

    // get the device type
    static var deviceModel: String {
        let device = UIDevice.current
        
        if device.userInterfaceIdiom == .phone {
            return "iPhone"
        } else if device.userInterfaceIdiom == .pad {
            return "iPad"
        } else if #available(iOS 14.0, *), device.userInterfaceIdiom == .mac {
            return "Mac"
        } else if device.userInterfaceIdiom == .tv {
            return "Apple TV"
        } else if device.userInterfaceIdiom == .carPlay {
            return "CarPlay"
        }
        
        return "Unknown"
    }
    
    // get the device type short form
    static var deviceTypeShort: String {
        let device = UIDevice.current
        
        switch device.userInterfaceIdiom {
        case .phone:
            return "mobile"
        case .pad:
            return "tablet"
        case .tv:
            return "tv"
        case .carPlay:
            return "car"
        case .mac:
            return "mac"
        default:
            return "unknown"
        }
    }
    
    static var isDynamicTextSizeLarge: Bool {
        let dynamicXtraLargeCategories: [UIContentSizeCategory] = [
            .extraLarge,
            .extraExtraLarge,
            .extraExtraExtraLarge,
            .accessibilityMedium,
            .accessibilityLarge,
            .accessibilityExtraLarge,
            .accessibilityExtraExtraLarge,
            .accessibilityExtraExtraExtraLarge
        ]
        
        let preferredCategory = UIApplication.shared.preferredContentSizeCategory
        print("Dynamic preferredCategory: \(preferredCategory)")
        let isDynamicTextLarge = dynamicXtraLargeCategories.contains(preferredCategory)
        print("Dynamic isDynamicTextSizeLarge: \(isDynamicTextLarge ? "YES" : "NO")")
        return isDynamicTextLarge
    }
    
    static func isDeviceSimulator() -> Bool {
        let deviceModel = self.deviceModel
        return deviceModel == "Simulator"
    }
}
