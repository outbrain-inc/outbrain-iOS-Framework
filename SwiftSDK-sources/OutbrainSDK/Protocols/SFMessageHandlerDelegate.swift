//
//  SFMessageHandlerDelegate.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 25/07/2023.
//

import Foundation
import WebKit

protocol SFMessageHandlerDelegate: SFWidgetDelegate {
    
    func messageHeightChange(_ height: CGFloat)
    func didClickOnRec(_ url: String)
    func didClickOnOrganicRec(_ url: String, orgUrl: String)
    func widgetEvent(eventName: String, additionalData: [String: Any])
}
