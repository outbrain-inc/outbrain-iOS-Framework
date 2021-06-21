//
//  SFWidget.swift
//  OBSDKiOS-SFWidget
//
//  Created by Alon Shprung on 8/10/20.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class SFWidget : UIView, SFMessageHandlerDelegate {
    private var webview: WKWebView?
    private var currentHeight = 0
    
    private var isLoading = false
    private var inTransition = false
    
    private struct SFWidgetProperties {
        let url: String
        let widgetId: String
        let installationKey: String?
        let userId: String?
    }
    
    private var sfWidgetProperties: SFWidgetProperties?
    private var messageHandler: SFScriptMessageHandler
    
    private var delegate: SFWidgetDelegate?
    
    // MARK: Initializers
    
    required init?(coder: NSCoder) {
        messageHandler = SFScriptMessageHandler()
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        messageHandler = SFScriptMessageHandler()
        super.init(frame: frame)
    }
    
    // MARK: Public methods
    
    func setProperties(delegate: SFWidgetDelegate, url: String, widgetId: String, installationKey: String? = nil, userId: String? = nil) {
        self.sfWidgetProperties = SFWidgetProperties(url: url, widgetId: widgetId, installationKey: installationKey, userId: userId)
        self.delegate = delegate
        messageHandler.delegate = self
        self.configureSFWidget()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        guard !inTransition, !isLoading, self.currentHeight > 1000 else { return }
        let contentOffsetY = scrollView.contentOffset.y
        let diffFromBottom = (scrollView.contentSize.height - scrollView.frame.size.height) - contentOffsetY
        if diffFromBottom < 1000 {
            self.loadMore()
        }
    }
    
    func viewWillTransition(coordinator: UIViewControllerTransitionCoordinator) {
        self.inTransition = true
        self.evaluateHeightScript(timeout: 300)
        // run after transition finished
        // https://stackoverflow.com/questions/26943808/ios-how-to-run-a-function-after-device-has-rotated-swift
        coordinator.animate(alongsideTransition: nil) { _ in
            self.viewDidTransition()
        }
    }
    
    func getCurrentHeight() -> CGFloat {
        return CGFloat(self.currentHeight)
    }
    
    func willDisplaySFWidgetCell(cell: SFWidgetCollectionViewCell) {
        willDisplaySFWidgetCellContentView(view: cell.contentView)
    }
    
    func willDisplaySFWidgetCell(cell: SFWidgetTableViewCell) {
        willDisplaySFWidgetCellContentView(view: cell.contentView)
    }
    
    // MARK: Private methods
    
    private func viewDidTransition() {
        self.inTransition = false
    }
    
    private func configureSFWidget() {
        guard self.webview == nil else { return }
        let preferences = WKPreferences()
        let webviewConf = WKWebViewConfiguration()
        
        let postMessageScript = WKUserScript(
            source: String(format: """
                window.%@ = {
                    postMessage: function (data) {
                        window.webkit.messageHandlers.%@.postMessage(String(data));
                    }
                };
            """, "ReactNativeWebView","ReactNativeWebView"),
            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
            forMainFrameOnly: true
        )
        
        let controller = WKUserContentController()
        controller.add(self.messageHandler, name: "ReactNativeWebView")
        
        controller.addUserScript(postMessageScript)
        preferences.javaScriptEnabled = true
        webviewConf.userContentController = controller
        webviewConf.allowsInlineMediaPlayback = true
        webviewConf.preferences = preferences
        
        self.webview = WKWebView(frame: self.frame, configuration: webviewConf)
        if let webview = self.webview {
            webview.scrollView.isScrollEnabled = false
            
            self.addSubview(webview)
            
            setFillParentConstraints(view: webview)
                
            webview.setNeedsLayout()
            
            // load url
            let widgetURL = self.getWidgetUrl()
            if let url = widgetURL {
                let request = URLRequest(url: url)
                webview.load(request)
                self.setNeedsLayout()
            }
        }
    }
    
    private func getWidgetUrl() -> URL? {
        guard let sfWidgetProperties = self.sfWidgetProperties else {
            return nil
        }
        let outbrainWidgetURL = "https://widgets.outbrain.com/reactNativeBridge/index.html"
        var components = URLComponents(string: outbrainWidgetURL)
        
        var queryItems : [URLQueryItem] = components?.queryItems ?? []
        queryItems.append(URLQueryItem(name: "permalink", value: sfWidgetProperties.url))
        queryItems.append(URLQueryItem(name: "widgetId", value: sfWidgetProperties.widgetId))
        
        if let userId = sfWidgetProperties.userId {
            queryItems.append(URLQueryItem(name: "userId", value: userId))
        }
        
        if let installationKey = sfWidgetProperties.installationKey {
            queryItems.append(URLQueryItem(name: "installationKey", value: installationKey))
        }
        
        components?.queryItems = queryItems
        
        return components?.url
    }
    
    private func loadMore() {
        isLoading = true
        evaluateLoadMore()
    }
    
    private func evaluateHeightScript(timeout: Int) {
        guard let webview = self.webview else { return }
        
        let script = """
            setTimeout(function() {
                let result = {}
                let height = document.body.scrollHeight
                result["height"] = height
                window['ReactNativeWebView'].postMessage(JSON.stringify(result))
            }, \(timeout));
        """

        webview.evaluateJavaScript(script)
    }
    
    private func evaluateLoadMore() {
        print("loading more --->")
        webview?.evaluateJavaScript("OBR.viewHandler.loadMore(); true;")
        evaluateHeightScript(timeout: 500)
    }
    
    private func willDisplaySFWidgetCellContentView(view: UIView) {
        for v in view.subviews {
            v.removeFromSuperview()
        }
        view.addSubview(self)
        
        setFillParentConstraints(view: self)
    }
    
    private func setFillParentConstraints(view: UIView) {
        guard let parentView = view.superview else { return }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        (view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor)).isActive = true
        (view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor)).isActive = true
        (view.topAnchor.constraint(equalTo: parentView.topAnchor)).isActive = true
        (view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)).isActive = true
        
    }
    
    // MARK: SFMessageHandlerDelegate
    
    internal func didHeightChanged(height: Int) {
        self.currentHeight = height
        self.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: CGFloat(height))
        self.setNeedsLayout()
        self.delegate?.didChangeHeight()
        
        if (self.isLoading) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false;
            }
        }
    }
    
    internal func didClickOnRec(url: String) {
        guard let url = URL(string: url) else { return }
        delegate?.onRecClick(url: url)
    }
    
    internal func didClickOnOrganicRec(url: String, orgUrl: String) {
        guard let url = URL(string: url) else { return }
        if let onOrganicRecClick = delegate?.onOrganicRecClick, let orgUrl = URL(string: orgUrl) {
            
            if var urlComponents = URLComponents(string: url.absoluteString) {
                var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
                queryItems.append(URLQueryItem(name: "noRedirect", value: "true"))
                urlComponents.queryItems = queryItems
                if let trafficUrl = urlComponents.url {
                    let request: URLRequest = URLRequest(url: trafficUrl)
                    URLSession.shared.dataTask(with: request) { (data, response, error) in
                        guard error == nil else {
                            print("Error reporting organic click: \(trafficUrl), error: \(error!)")
                            return
                        }
                        if let httpResponse = response as? HTTPURLResponse {
                            print("Report organic click response code: \(httpResponse.statusCode)")
                        }
                    }.resume()

                }
            }
            onOrganicRecClick(orgUrl)
        } else {
            delegate?.onRecClick(url: url)
        }
    }
}
