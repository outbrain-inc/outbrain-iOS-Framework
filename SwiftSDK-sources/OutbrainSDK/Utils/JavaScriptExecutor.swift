//
//  JSExecuter.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 17/08/2023.
//

import WebKit

struct JavaScriptExecutor {
    private var webView: WKWebView?
    init() { }
    
    private func executeJavaScript(_ code: String, completion: ((Result<Any?, Error>) -> Void)? = nil) {
        guard let webView = self.webView else {
            completion?(.failure(NSError(domain: "JavaScriptExecutor", code: -1, userInfo: [NSLocalizedDescriptionKey: "WebView not set"])))
            return
        }
        
        webView.evaluateJavaScript(code) { result, error in
            if let error = error {
                completion?(.failure(error))
            } else {
                completion?(.success(result))
            }
        }
    }
    
    mutating func setWebView(view: WKWebView) {
        self.webView = view
    }
    
    func setViewData(from: Int, to: Int, width: Int, height: Int) {
        let code = "OBBridge.viewHandler.setViewData(\(width), \(height), \(from), \(to))"
        self.executeJavaScript(code) { self.resolver($0) }
    }
    
    func toggleDarkMode(_ displayDark: Bool) {
        Outbrain.logger.log("Toggle Darkmode")
        let code = "OBBridge.darkModeHandler.setDarkMode(\(displayDark ? "true" : "false"))"
        self.executeJavaScript(code) { self.resolver($0) }
    }
                            
    func loadMore() {
        let code = "OBR.viewHandler.loadMore(); true;"
        self.executeJavaScript(code) { self.resolver($0) }
    }
    
    func evaluateHeight() {
        let code = "OBBridge.resizeHandler.getCurrentHeight();"
        self.executeJavaScript(code) { self.resolver($0) }
    }
    
    private func resolver(_ result: Result<Any?, Error>) {
        if case .failure(let error) = result {
            Outbrain.logger.error("JS Error: \(error)")
        }
    }
}
