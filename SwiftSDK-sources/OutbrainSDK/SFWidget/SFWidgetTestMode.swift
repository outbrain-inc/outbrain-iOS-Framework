//
//  SFWidgetTestMode.swift
//  OutbrainSDK
//
//  Created by Oren Pinkas on 27/08/2024.
//

import Foundation
import WebKit

public class SFWidgetTestMode: SFWidget {
    var httpMessageHandler: HttpMessageHandler?
    
    override func configureSFWidget() {
        super.configureSFWidget()
        
        guard let webView = self.webView else { return }
        
        let reportHttpRequestScript = """
        // Fetch override
        const originalFetch = window.fetch;
        window.fetch = function(input, init) {
            const url = typeof input === 'string' ? input : input.url;
            if (url.includes('outbrain.com') || url.includes('log.outbrainimg.com')) {
                console.log('Fetch request is being sent:', url, init);
                window.webkit.messageHandlers.httpRequest.postMessage({ url: url, options: init });
            }
            return originalFetch.apply(this, arguments);
        };
        
        // sendBeacon override
        const originalSendBeacon = navigator.sendBeacon;
        navigator.sendBeacon = function(url, data) {
            if (url.includes('outbrain.com') || url.includes('log.outbrainimg.com')) {
                console.log('Beacon is being sent to: ' + url);
                window.webkit.messageHandlers.httpRequest.postMessage({url: url, options: data});
            }
            return originalSendBeacon.apply(this, arguments);
        };
        """
        let script = WKUserScript(source: reportHttpRequestScript, injectionTime: .atDocumentEnd, forMainFrameOnly: false)

        // Add the additional script to the existing user content controller
        webView.configuration.userContentController.addUserScript(script)
        
        // Add an additional message handler
        httpMessageHandler = HttpMessageHandler()
        webView.configuration.userContentController.add(httpMessageHandler!, name: "httpRequest")
    }
    
    public func configure(with delegate: (any SFWidgetDelegate)?, url: String, widgetId: String, widgetIndex: Int, installationKey: String, userId: String?, darkMode: Bool, isSwiftUI: Bool, httpHandler: HttpHandler) {
        super.configure(with: delegate, url: url, widgetId: widgetId, widgetIndex: widgetIndex, installationKey: installationKey, userId: userId, darkMode: darkMode, isSwiftUI: isSwiftUI)
        
        httpMessageHandler?.delegate = httpHandler
    }
}
