//
//  SFScriptMessageHandler.swift
//  OBSDKiOS-SFWidget
//
//  Created by Alon Shprung on 8/10/20.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import WebKit

class SFScriptMessageHandler : NSObject , WKScriptMessageHandler {
    
    var delegate: SFMessageHandlerDelegate?

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard message.name == "ReactNativeWebView" else { return }
        if let msgBody = message.body as? String,
            let data = msgBody.data(using: .utf8) {
            do {
                let jsObj = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
                if let jsonObjDict = jsObj as? Dictionary<String, Any> {
                    if let height = jsonObjDict["height"] as? Int {
                        delegate?.didHeightChanged(height: height)
                    }
                    if let url = jsonObjDict["url"] as? String,
                        let type = jsonObjDict["type"] as? String {
                        if type == "organic-rec",
                            let orgUrl = jsonObjDict["orgUrl"] as? String {
                            delegate?.didClickOnOrganicRec(url: url, orgUrl: orgUrl)
                        } else {
                            delegate?.didClickOnRec(url: url)
                        }
                    }
                }
            } catch {
                print("having trouble converting msgBody to a dictionary")
            }
        }
    }
}
