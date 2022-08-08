//
//  CustomSFWidgetDelegate.swift
//  SwiftUI-Bridge
//
//  Created by Oded Regev on 07/08/2022.
//  Copyright © 2022 Outbrain inc. All rights reserved.
//

import Foundation
import OutbrainSDK

// Our CustomSFWidgetDelegate implementation class that expects to find a SFWidgetObservable object
// in the environment, and set if needed.
class CustomSFWidgetDelegate : NSObject {
    var sfWidgetObservable: SFWidgetObservable?
}

extension CustomSFWidgetDelegate : SFWidgetDelegate {
    
    func onRecClick(_ url: URL) {
        if let sfWidgetObservable = self.sfWidgetObservable {
            sfWidgetObservable.url = url
            sfWidgetObservable.showSafari = true
        }
    }
    
    func didChangeHeight(_ newHeight: CGFloat) {
        print("didChangeHeight \(newHeight)")
        sfWidgetObservable?.widgetHeight = newHeight
    }
}
