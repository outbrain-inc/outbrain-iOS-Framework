//
//  HttpMessageHandler.swift
//  OutbrainSDK
//
//  Created by Oren Pinkas on 27/08/2024.
//

import Foundation
import WebKit

class HttpMessageHandler: NSObject, WKScriptMessageHandler {
    
    weak var delegate: HttpHandler?
    
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        
        if message.name == "httpRequest", let messageBody = message.body as? [String: Any] {
            if let url = messageBody["url"] as? String,
               let options = messageBody["options"],
               let url = URL(string: url),
               let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    
                let host = components.host
                let path = components.path
                var params: [String: String] = [:]
                components.queryItems?.forEach({ item in
                    params[item.name] = item.value
                })
                
                let request: [String: Any?] = [
                    "url": url.absoluteString,
                    "host": host,
                    "path": path,
                    "query": params,
                    "options": options
                ]
            
                guard host == "log.outbrainimg.com" else { return }
                delegate?.handleRequest("viewability", request: request)
            }
        }
        return
    }
}

public protocol HttpHandler: NSObjectProtocol {
    func handleRequest(_ type:String, request: [String: Any?])
}
