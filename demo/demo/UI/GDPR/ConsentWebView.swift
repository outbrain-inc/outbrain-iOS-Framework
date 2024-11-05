//
//  ConsentWebView.swift
//  demo
//
//  Created by Leonid Lemesev on 05/11/2024.
//


import SwiftUI
@preconcurrency import WebKit


struct ConsentWebView: UIViewRepresentable {
    
    let url: URL
    let onConsentReceived: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        UserDefaults.standard.removeObject(forKey: "IABConsent_ConsentString")
        UserDefaults.standard.synchronize()
        
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Load the URL
        let request = URLRequest(url: url)
        uiView.load(request)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ConsentWebView
        
        init(_ parent: ConsentWebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Intercept the request URL
            if let url = navigationAction.request.url?.absoluteString, url.hasPrefix("consent://") {
                // Extract the consent string
                let consentString = url.replacingOccurrences(of: "consent://", with: "")
                
                
                UserDefaults.standard.set(consentString, forKey: "IABConsent_ConsentString")
                UserDefaults.standard.synchronize()
                
                
                parent.onConsentReceived(consentString)
                decisionHandler(.cancel) // Cancel the navigation
                return
            }
            decisionHandler(.allow) // Allow other requests
        }
    }
}
