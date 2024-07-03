//
//  SFWidgetMessageHandler.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 25/07/2023.
//

import Foundation
import WebKit

class SFWidgetMessageHandler: NSObject, WKScriptMessageHandler {
    let messageHandler = "message-handler"
    weak var delegate: SFWidget?
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        do {
            guard message.name == "ReactNativeWebView" else {
                Outbrain.logger.debug("SFWidgetMessageHandler - message is not ReactNativeWebView", domain: self.messageHandler)
                return
            }
            
            guard let jsonString = message.body as? String else {
                Outbrain.logger.debug("SFWidgetMessageHandler - Invalid message body", domain: self.messageHandler)
                return
            }
            
            guard let data = jsonString.data(using: .utf8) else {
                Outbrain.logger.debug("SFWidgetMessageHandler - Error converting message body to data", domain: self.messageHandler)
                return
            }
            
            let msgBody = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            
            self.callDelegateOnChangeHeight(msgBody)
            self.handleBridgeParams(msgBody)
            self.handleTParam(msgBody)
            self.handleClickMessage(msgBody)
            self.callDelegateOnValidEvents(msgBody)
            self.handleErrorMessage(msgBody)
            self.handleSettingsMessage(msgBody)
        } catch {
            let errorMsg = "Exception in SFWidgetMessageHandler - \(error)"
            Outbrain.logger.error("SFWidgetMessageHandler - Error converting message body to data", domain: self.messageHandler)
            Outbrain.logger.error(errorMsg, domain: self.messageHandler)
            delegate?.errorReporter?.setMessage(message: errorMsg).reportErrorToServer()
        }
    }
    
    private func handleBridgeParams(_ msg: [String: Any]) {
        if let bridgeParam = msg["bridgeParams"] as? String {
            Outbrain.logger.debug("SFWidgetMessageHandler received bridgeParam: \(bridgeParam)", domain: self.messageHandler)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: SFWIDGET_BRIDGE_PARAMS_NOTIFICATION), object: self, userInfo: ["bridgeParams": bridgeParam])
        }
    }
    
    private func handleTParam(_ msg: [String: Any]) {
        if let tParam = msg["t"] as? String {
            Outbrain.logger.debug("SFWidgetMessageHandler received t param: \(tParam) - Not posting notification (using bridgeParams instead)", domain: self.messageHandler)
        }
    }
    
    
    private func handleClickMessage(_ msg: [String: Any]) {
        guard let urlString = msg["url"] as? String, BridgeUtils.isValidURL(urlString) else {
            return
        }
        
        if let type = msg["type"] as? String, type == "organic-rec", let orgUrl = msg["orgUrl"] as? String {
            self.delegate?.didClickOnOrganicRec(urlString, orgUrl: orgUrl)
            return
        }
        
        self.delegate?.onRecClick(URL(string: urlString)!)
    }
    
    private func handleErrorMessage(_ msg: [String: Any]) {
        if let errorMsg = msg["errorMsg"] as? String {
            let errorMsgWithPrefix = "Bridge: \(errorMsg)"
            delegate?.errorReporter?.setMessage(message: errorMsgWithPrefix).reportErrorToServer()
        }
    }
    
    private func callDelegateOnChangeHeight(_ msg: [String: Any]) {
        if let height = msg["height"] as? CGFloat, msg["sender"] as? String == "resize"  {
            self.delegate?.messageHeightChange(height)
        }
    }
    
    private func callDelegateOnValidEvents(_ msg: [String: Any]?) {
        if let eventDict = msg?["event"] as? [String: Any] {
            var eventData = eventDict
            if let eventName = eventData.removeValue(forKey: "name") as? String {
                if eventData.keys.compactMap({ $0 }).count == eventData.keys.count {
                    self.delegate?.widgetEvent(eventName: eventName, additionalData: eventData)
                }
            }
        }
    }
    
    private func handleSettingsMessage(_ msg: [String: Any]) {
        guard let settings = msg["settings"] as? [String: Any] else { return }
        
        self.delegate?.onSettingsReceived(settings)
    }
}

