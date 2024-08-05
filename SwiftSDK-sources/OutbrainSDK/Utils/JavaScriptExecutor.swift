//
//  JSExecuter.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 17/08/2023.
//

import WebKit

struct JavaScriptExecutor {
    
    private var webView: WKWebView?
    
    
    private func executeJavaScript(
        _ code: String,
        completion: ((Result<Any?, Error>) -> Void)? = nil
    ) {
        guard let webView else {
            completion?(.failure(NSError(
                domain: "JavaScriptExecutor", code: -1,
                userInfo: [NSLocalizedDescriptionKey: "WebView not set"]
            )))
            return
        }
        
        webView.evaluateJavaScript(code) { result, error in
            if let error {
                completion?(.failure(error))
            } else {
                completion?(.success(result))
            }
        }
    }
    
    
    mutating func setWebView(view: WKWebView) {
        webView = view
    }
    
    
    func setViewData(from: Int, to: Int, width: Int, height: Int) {
        let code = "OBBridge.viewHandler.setViewData(\(width), \(height), \(from), \(to))"
        executeJavaScript(code) { resolver($0) }
    }
    
    
    func toggleDarkMode(_ displayDark: Bool) {
        Outbrain.logger.log("Toggle Darkmode")
        let code = "OBBridge.darkModeHandler.setDarkMode(\(displayDark ? "true" : "false"))"
        executeJavaScript(code) { resolver($0) }
    }
                            
    func loadMore() {
        let code = "OBR.viewHandler.loadMore(); true;"
        executeJavaScript(code) { resolver($0) }
    }
    
    func evaluateHeight() {
        let code = "OBBridge.resizeHandler.getCurrentHeight();"
        executeJavaScript(code) { resolver($0) }
    }
    
    private func resolver(_ result: Result<Any?, Error>) {
        guard case .failure(let error) = result else { return }
        Outbrain.logger.error("JS Error: \(error)")
    }
}
