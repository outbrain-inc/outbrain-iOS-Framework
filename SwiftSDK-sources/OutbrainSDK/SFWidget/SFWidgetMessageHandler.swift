//
//  SFWidgetMessageHandler.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 25/07/2023.
//

import Foundation
import WebKit

class SFWidgetMessageHandler: NSObject, WKScriptMessageHandler {
    
    private let messageHandler = "message-handler"
    weak var delegate: SFWidget?
    
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "ReactNativeWebView" else {
            Outbrain.logger.debug(
                "SFWidgetMessageHandler - message is not ReactNativeWebView",
                domain: messageHandler
            )
            return
        }
        
        guard let jsonString = message.body as? String else {
            Outbrain.logger.debug(
                "SFWidgetMessageHandler - Invalid message body",
                domain: messageHandler
            )
            return
        }
        
        guard let data = jsonString.data(using: .utf8) else {
            Outbrain.logger.debug(
                "SFWidgetMessageHandler - Error converting message body to data",
                domain: messageHandler
            )
            return
        }
            
        do {
            let msgBody = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] ?? [:]
            
            callDelegateOnChangeHeight(msgBody)
            handleBridgeParams(msgBody)
            handleTParam(msgBody)
            handleClickMessage(msgBody)
            callDelegateOnValidEvents(msgBody)
            handleErrorMessage(msgBody)
            handleSettingsMessage(msgBody)
        } catch {
            let errorMsg = "Exception in SFWidgetMessageHandler - \(error)"
            Outbrain.logger.error("SFWidgetMessageHandler - Error converting message body to data", domain: messageHandler)
            Outbrain.logger.error(errorMsg, domain: messageHandler)
            delegate?.errorReporter?.setMessage(message: errorMsg).reportErrorToServer()
        }
    }
    
    
    private func handleBridgeParams(_ msg: [String: Any]) {
        guard let bridgeParam = msg["bridgeParams"] as? String else { return }
        
        Outbrain.logger.debug(
            "SFWidgetMessageHandler received bridgeParam: \(bridgeParam)",
            domain: messageHandler
        )
        
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: SFConsts.SFWIDGET_BRIDGE_PARAMS_NOTIFICATION),
            object: self,
            userInfo: ["bridgeParams": bridgeParam]
        )
    }
    
    
    private func handleTParam(_ msg: [String: Any]) {
        guard let tParam = msg["t"] as? String else { return }
        
        Outbrain.logger.debug(
            "SFWidgetMessageHandler received t param: \(tParam) - Not posting notification (using bridgeParams instead)",
            domain: messageHandler
        )
    }
    
    
    private func handleClickMessage(_ msg: [String: Any]) {
        guard let urlString = msg["url"] as? String,
              BridgeUtils.isValidURL(urlString) else {
            return
        }
        
        if let type = msg["type"] as? String, type == "organic-rec",
           let orgUrl = msg["orgUrl"] as? String {
            delegate?.didClickOnOrganicRec(urlString, orgUrl: orgUrl)
            return
        }
        
        delegate?.onRecClick(URL(string: urlString)!)
    }
    
    
    private func handleErrorMessage(_ msg: [String: Any]) {
        guard let errorMsg = msg["errorMsg"] as? String else { return }
        
        let errorMsgWithPrefix = "Bridge: \(errorMsg)"
        delegate?.errorReporter?.setMessage(message: errorMsgWithPrefix).reportErrorToServer()
    }
    
    
    private func callDelegateOnChangeHeight(_ msg: [String: Any]) {
        guard let height = msg["height"] as? CGFloat, msg["sender"] as? String == "resize" else { return }
        delegate?.messageHeightChange(height)
    }
    
    
    private func callDelegateOnValidEvents(_ msg: [String: Any]?) {
        guard var eventDict = msg?["event"] as? [String: Any] else { return }
        
        if let eventName = eventDict.removeValue(forKey: "name") as? String,
           eventDict.keys.compactMap({ $0 }).count == eventDict.keys.count {
            delegate?.widgetEvent(
                eventName: eventName,
                additionalData: eventDict
            )
        }
    }
    
    
    private func handleSettingsMessage(_ msg: [String: Any]) {
        guard let settings = msg["settings"] as? [String: Any] else { return }
        
        delegate?.onSettingsReceived(settings)
    }
}

