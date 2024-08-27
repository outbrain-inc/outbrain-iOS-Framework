//
//  HttpMessageHandler.swift
//  OutbrainSDK
//
//  Created by Oren Pinkas on 27/08/2024.
//

import Foundation
import WebKit

class HttpMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var delegate: SFWidget?
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        
        if message.name == "httpRequest", let messageBody = message.body as? [String: Any] {
            if let url = messageBody["url"] as? String, let options = messageBody["options"] {
                
                if let url = URL(string: url),
                   let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    
                    let host = components.host
                    let path = components.path
                    var params: [String: String] = [:]
                    if let queryItems = components.queryItems {
                        for item in queryItems {
                            params[item.name] = item.value
                        }
                    }
                    
                    let request: [String: Any?] = [
                        "url": url.absoluteString,
                        "host": host,
                        "path": path,
                        "query": params,
                        "options": options
                    ]
                    
                    switch host {
                    case "log.outbrainimg.com":
                        delegate?.httpHandler?.handleRequest("viewability", request: request)
                        break
                    default:
                        break
                    }
                }
            }
            return
        }
    }
}
