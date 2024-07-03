//
//  SFWidget.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 25/07/2023.
//

import Foundation
import WebKit

let SFWIDGET_T_PARAM_NOTIFICATION = "SFWidget_T_Param_Ready"
let SFWIDGET_BRIDGE_PARAMS_NOTIFICATION = "SFWidget_Bridge_Params_Ready"
let THRESHOLD_FROM_BOTTOM: CGFloat = 500
//bottom
public class SFWidget: UIView {
    var currentHeight: CGFloat = 0
    var isLoading: Bool = false
    var isWidgetEventsEnabled: Bool = false
    var inTransition: Bool = false
    var url: String?
    var widgetId: String?
    var installationKey: String?
    var userId: String?
    var widgetIndex: Int = 0
    var isSwiftUI: Bool = false
    private lazy var swiftUiConfigureDone = false
    var tParam: String?
    var bridgeParams: String?
    var darkMode: Bool = false
    weak var delegate: SFWidgetDelegate?
    var messageHandler: SFWidgetMessageHandler!
    var bridgeUrlBuilder: BridgeUrlBuilder?
    var jsExec: JavaScriptExecutor!
    var webview: WKWebView!
    var hiddenWebView: WKWebView?
    var bridgeParamsObserver: NSObjectProtocol?
    var tParamObserver: NSObjectProtocol?
    var viewabilityTimerHandler: ViewabilityTimerHandler!
    var errorReporter: OBErrorReport?
    var settings: [String: Any] = [:]
    static var isFlutter: Bool = false;
    public static var infiniteWidgetsOnTheSamePage: Bool = false;
    static var globalBridgeParams: String?
    
    /**
       External Id public value
       app developer should set "external ID" and the optional "secondary external ID" as shown below:
     */
    public var extId: String?
    public var extSecondaryId: String?
    
    /**
     Outbrain uses the odb parameter pubImpId to get the session ID/ click identifier from the publisher.
     */
    public var OBPubImp: String?
    /**
     Initializes a new instance of the custom view with the specified frame.

     - Parameter frame: A `CGRect` that defines the initial size and position of the view within its superview's coordinate system.

     This initializer sets up the view's initial state and invokes the common initialization method.

     Usage Example:

     let customView = CustomView(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
     **/
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    /**
     Initializes a new instance of the custom view based on data from the storyboard or a NIB file.

     - Parameter coder: An `NSCoder` object used to decode the view from an archive.

     This required initializer is called when the view is created from a storyboard or NIB file. It invokes the common initialization method to set up the view's initial state.

     - Important: You should not override this initializer unless necessary.
     **/
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        self.messageHandler = SFWidgetMessageHandler()
        self.jsExec = JavaScriptExecutor()
        self.viewabilityTimerHandler = ViewabilityTimerHandler()
        self.configureSFWidget()        
        self.messageHandler.delegate = self
    }

    /**
     Configures the custom widget with the provided settings.

     - Parameter delegate: An object conforming to the `SFWidgetDelegate` protocol that will handle widget events and interactions.
     - Parameter url: The URL associated with the widget.
     - Parameter widgetId: A unique identifier for the widget.
     - Parameter installationKey: A key used for widget installation.

     This method allows you to configure the custom widget with the provided settings, such as the delegate, URL, widget ID, and installation key. Additional configuration options are set to their default values. Use this method when you want to quickly configure the widget with basic settings.

     - Note: If you need to configure more advanced options, consider using the `configure` method with additional parameters.

     Usage Example:
     ```swift
     widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", installationKey: "abcdef")
     */
    public func configure(with delegate: SFWidgetDelegate, url: String, widgetId: String, installationKey: String) {
        self.configure(with: delegate, url: url, widgetId: widgetId, widgetIndex: 0, installationKey: installationKey, userId: nil, darkMode: false, isSwiftUI: false)
    }

    /**
     Configures the custom widget with advanced settings.

     - Parameter delegate: An object conforming to the `SFWidgetDelegate` protocol that will handle widget events and interactions.
     - Parameter url: The URL associated with the widget.
     - Parameter widgetId: A unique identifier for the widget.
     - Parameter widgetIndex: An integer representing the index of the widget.
     - Parameter installationKey: A key used for widget installation.
     - Parameter userId: An optional user identifier, if applicable.
     - Parameter darkMode: A boolean indicating whether the widget should be displayed in dark mode.

     Use this method to configure the custom widget with advanced settings beyond the basic configuration. You can specify the delegate, URL, widget ID, widget index, installation key, user ID, and dark mode preference.

     - Note: If you want to use this widget in a SwiftUI environment, set `isSwiftUI` to `true` when calling this method.

     Usage Example:
     ```swift
     widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", widgetIndex: 0, installationKey: "abcdef", userId: "user123", darkMode: true)
     */
    public func configure(with delegate: SFWidgetDelegate, url: String, widgetId: String, widgetIndex: Int, installationKey: String, userId: String?, darkMode: Bool) {
        self.configure(with: delegate, url: url, widgetId: widgetId, widgetIndex: widgetIndex, installationKey: installationKey, userId: userId, darkMode: darkMode, isSwiftUI: false)
    }

    /**
     Configures the custom widget with basic settings.

     - Parameter delegate: An optional object conforming to the `SFWidgetDelegate` protocol that will handle widget events and interactions.
     - Parameter url: The URL associated with the widget.
     - Parameter widgetId: A unique identifier for the widget.
     - Parameter installationKey: A key used for widget installation.

     Use this method to configure the custom widget with essential settings. You can specify the delegate, URL, widget ID, and installation key.

     If you do not provide a delegate, certain widget interactions may not be handled.

     - Note: After configuring the widget, you should call the `initialLoadUrl` method to load the widget content.

     Usage Example:
     ```swift
     widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", installationKey: "abcdef")
     */
    public func configure(with delegate: SFWidgetDelegate?,
                   url: String,
                   widgetId: String,
                   installationKey: String) {
        
        if (self.swiftUiConfigureDone) {
           return;
        }

        self.delegate = delegate
        self.url = url
        self.widgetId = widgetId
        self.installationKey = installationKey
        self.errorReporter = OBErrorReport(url: self.url, widgetId: self.widgetId)
        self.bridgeUrlBuilder = BridgeUrlBuilder(url: self.url, widgetId: self.widgetId, installationKey: self.installationKey)
        self.configureBridgeNotificationHandlers()
        
        if self.widgetIndex > 0 {
            if (SFWidget.globalBridgeParams != nil && SFWidget.infiniteWidgetsOnTheSamePage) {
                // we have the "page context" already from fetching widgetIdx=0 (stored in globalBridgeParams)
                // Therefore, we can load the widget with idx > 0 immediately
                self.initialLoadUrl()
            }
            else {
                print("differ fetching until we'll have the \"t\" or \"bridgeParams\" ready")
            }
        }
        else {
            SFWidget.globalBridgeParams = nil
            self.initialLoadUrl()
        }
        
        if self.isSwiftUI == true {
            self.handleSwiftUI()
            self.swiftUiConfigureDone = true
        }
    }

    /**
     Configures the custom widget with advanced settings.

     - Parameter delegate: An optional object conforming to the `SFWidgetDelegate` protocol that will handle widget events and interactions.
     - Parameter url: The URL associated with the widget.
     - Parameter widgetId: A unique identifier for the widget.
     - Parameter widgetIndex: An integer representing the index of the widget.
     - Parameter installationKey: A key used for widget installation.
     - Parameter userId: An optional user identifier associated with the widget.
     - Parameter darkMode: A Boolean flag indicating whether to enable dark mode for the widget.
     - Parameter isSwiftUI: A Boolean flag indicating whether the widget is integrated with SwiftUI.

     Use this method to configure the custom widget with advanced settings. You can specify the delegate, URL, widget ID, installation key, widget index, user ID, dark mode, and SwiftUI integration.

     If you do not provide a delegate, certain widget interactions may not be handled. The user ID, dark mode, and SwiftUI integration are optional and can be omitted if not needed.

     - Note: After configuring the widget, you should call the `initialLoadUrl` method to load the widget content.

     Usage Example:
     ```swift
     widget.configure(with: myDelegate, url: "https://example.com/page1", widgetId: "MB_3", widgetIndex: 0, installationKey: "abcdef", userId: "user123", darkMode: true, isSwiftUI: false)
     */
    public func configure(with delegate: SFWidgetDelegate?,
                   url: String,
                   widgetId: String,
                   widgetIndex: Int,
                   installationKey: String,
                   userId: String?,
                   darkMode: Bool,
                   isSwiftUI: Bool) {
        self.delegate = delegate
        self.widgetIndex = widgetIndex
        self.darkMode = darkMode
        self.setUserId(userId)
        self.isSwiftUI = isSwiftUI
        self.configure(with: delegate, url: url, widgetId: widgetId, installationKey: installationKey)
    }

    private func configureSFWidget() {
        if self.webview != nil {
            return
        }

        let preferences = WKPreferences()
        let webviewConf = WKWebViewConfiguration()

        let jsInitScript = """
            window.ReactNativeWebView = {
                postMessage: function (data) {
                    window.webkit.messageHandlers.ReactNativeWebView.postMessage(String(data));
                }
            }
            """

        let script = WKUserScript(source: jsInitScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)

        let controller = WKUserContentController()
        controller.add(self.messageHandler!, name: "ReactNativeWebView")

        controller.addUserScript(script)
        preferences.javaScriptEnabled = true
        webviewConf.userContentController = controller
        webviewConf.allowsInlineMediaPlayback = true
        webviewConf.preferences = preferences

        self.webview = WKWebView(frame: self.frame, configuration: webviewConf)
        self.webview.scrollView.isScrollEnabled = false
        self.webview.isOpaque = false
        self.webview.uiDelegate = self
        self.webview.navigationDelegate = self
        self.setWebViewInspectable(inspectable: SFConsts.isInspectable)
        self.addSubview(self.webview)
        BridgeUtils.addConstraintsToParentView(view: self.webview)
        self.jsExec.setWebView(view: self.webview)
        self.webview.setNeedsLayout()

    }
    
    public static func setIsFlutter(value: Bool) {
        isFlutter = value;
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.window != nil {
            // The view has been added to a window
            print("View added to window")
            if self.swiftUiConfigureDone == true {
                self.handleSwiftUI()
            }
        } else {
            // The view has been removed from a window
            print("View removed from window")
        }
    }
    
    func configureBridgeNotificationHandlers() {
        let bridgeParamsNotification = NSNotification.Name(rawValue: SFWIDGET_BRIDGE_PARAMS_NOTIFICATION)
        
        self.bridgeParamsObserver = NotificationCenter.default.addObserver(forName: bridgeParamsNotification, object: nil, queue: nil) { notification in
            Outbrain.logger.log("SFWidget received \"bridgeParams\" notification")
            self.receiveBridgeParamsNotification(notification)
            
            if (self.widgetIndex == 0) {
                // we are already loaded
                return;
            }
            DispatchQueue.main.async {
                self.initialLoadUrl()
            }
        }
    }
    
    func receiveBridgeParamsNotification(_ notification: Notification) {
        if notification.name.rawValue == SFWIDGET_BRIDGE_PARAMS_NOTIFICATION {
            if let bridgeParams = notification.userInfo?["bridgeParams"] as? String {
                self.bridgeParams = bridgeParams
                SFWidget.globalBridgeParams = self.bridgeParams
            }
            Outbrain.logger.log("Successfully received SFWIDGET_BRIDGE_PARAMS_NOTIFICATION - \(String(describing: self.bridgeParams))")
            if let bridgeParamsObserver = self.bridgeParamsObserver {
                NotificationCenter.default.removeObserver(bridgeParamsObserver)
            }
            
        }
    }

    
    func setWebViewInspectable(inspectable: Bool) {
#if compiler(>=5.8) && os(iOS) && DEBUG
        if #available(iOS 16.4, *) {
            self.webview.isInspectable = inspectable
        }
#endif
    }
    
    func setUserId(_ userId: String?) {
        
        if UIDevice.current.model == "Simulator" {
            self.userId = "F22700D5-1D49-42CC-A183-F3676526035F" // dev hack to test Videos
            return
        }
        
        if OBAppleAdIdUtil.isOptedOut {
            self.userId = nil
            return
        }
        
        if let userId = userId {
            self.userId = userId
            return
        }
        
        if OBAppleAdIdUtil.advertiserId != "null" {
            self.userId = OBAppleAdIdUtil.advertiserId
        }
    }

    func initialLoadUrl() {
        if let widgetURL = bridgeUrlBuilder?.addPermalink(url: self.url)
            .addDarkMode(isDarkMode: self.darkMode)
            .addTParam(tParam: self.tParam)
            .addBridgeParams(bridgeParams: self.bridgeParams)
            .addEvents(widgetEvents: self.isWidgetEventsEnabled ? .all: .no)
            .addExternalId(extId: self.extId)
            .addExternalSecondaryId(extid2: self.extSecondaryId)
            .addOBPubImp(pubImpId: self.OBPubImp)
            .addUserId(userId: self.userId)
            .addOSTracking()
            .addWidgetIndex(index: self.widgetIndex)
            .addIsFlutter(isFlutter: SFWidget.isFlutter)
            .build() {
            
            Outbrain.logger.log("Bridge URL: \(widgetURL)")

            let urlRequest = URLRequest(url: widgetURL)
            self.webview.load(urlRequest)
            self.webview.setNeedsLayout()
        }
    }


    public func getCurrentHeight() -> CGFloat {
        return self.currentHeight
    }

    public func enableEvents() {
        self.isWidgetEventsEnabled = true
    }
    
    // MARK: - toggle darkMode
    public func toggleDarkMode(_ displayDark: Bool) {
        self.jsExec.toggleDarkMode(displayDark)
    }

    // MARK: - UITableView
    public func willDisplay(_ cell: SFWidgetTableCell) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(self)
        BridgeUtils.addConstraintsToFillParent(view: self)
    }
    
    public func willDisplay(_ cell: SFWidgetCollectionCell) {
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        cell.contentView.addSubview(self)
        BridgeUtils.addConstraintsToFillParent(view: self)
    }
    
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //check if this check happens from bottom or from bottom view port
        //check if we can move responsebility of load more to js bridge
        self.viewabilityTimerHandler.handleViewability(sfWidget: self, containerView: scrollView) {viewStatus, width ,height  in
            self.jsExec.setViewData(from: viewStatus.visibleFrom, to: viewStatus.visibleTo, width: width, height: height)
        }
        
        if self.isLoading || self.inTransition || self.currentHeight <= THRESHOLD_FROM_BOTTOM {
            return
        }

        let contentOffsetY = scrollView.contentOffset.y
        let diffFromBottom = (scrollView.contentSize.height - scrollView.frame.size.height) - contentOffsetY
        if diffFromBottom < THRESHOLD_FROM_BOTTOM {
            self.loadMore()
        }
    }

    // this function is used to count a "new" page view on user back action on a specific publisher (bild.de)
    public func reportPageViewOnTheSameWidget() {
        Outbrain.logger.log("Outbrain SDK reportPageViewOnTheSameWidget() is called")
        
        let webviewConf = WKWebViewConfiguration()
        self.hiddenWebView = WKWebView(frame: self.frame, configuration: webviewConf)
        
        if let widgetURL = bridgeUrlBuilder?.addPermalink(url: self.url).build() {
            let urlRequest = URLRequest(url: widgetURL)
            self.hiddenWebView?.load(urlRequest)
        }
    }

    public func loadMore() {
        self.isLoading = true
        NSLog("loading more --->")
        Outbrain.logger.debug("load-more-recs", domain: "sfWidfet-handler")
        self.jsExec.loadMore()
        self.jsExec.evaluateHeight()
    }
    
    private func handleSwiftUI() {
        self.viewabilityTimerHandler.handleSwiftUI(sfWidget: self) { viewStatus, width ,height, shouldLoadMore in
            self.jsExec.setViewData(from: viewStatus.visibleFrom, to: viewStatus.visibleTo, width: width, height: height)
            if (!shouldLoadMore) {
                return
            }
            
            if self.isLoading || self.inTransition || self.currentHeight <= THRESHOLD_FROM_BOTTOM {
                return
            }
            
            self.loadMore()
        }
    }
    
    public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.inTransition = true
        
        // Run after the transition is finished
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.jsExec.evaluateHeight()
            self?.inTransition = false
        }
    }
}

extension SFWidget: SFMessageHandlerDelegate {
    
    func widgetEvent(eventName: String, additionalData: [String: Any]) {
        if let delegate = self.delegate {
            delegate.widgetEvent?(eventName, additionalData: additionalData)
        }
    }
    
    @objc func messageHeightChange(_ height: CGFloat) {
        self.currentHeight = CGFloat(height)
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: CGFloat(height))
        self.setNeedsLayout()
        
        self.delegate?.didChangeHeight?(self.currentHeight)
        self.delegate?.didChangeHeight?()

        if self.isLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isLoading = false
            }
        }
    }

    func didClickOnRec(_ url: String) {
        if let recURL = URL(string: url) {
            DispatchQueue.main.async {
                self.delegate?.onRecClick(recURL)
            }
        }
    }

    func didClickOnOrganicRec(_ url: String, orgUrl: String) {
        guard let recURL = URL(string: url) else { return }
        guard var components = URLComponents(string: url) else { return }
        components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "noRedirect", value: "true")]
        
        if let trafficURL = components.url {
            self.clickOpenRequest(for: trafficURL) { result in
                if case .failure(let error) = result {
                    let errorMsg = "Error reporting organic click: \(trafficURL), error: \(error)"
                    Outbrain.logger.error(errorMsg, domain: "didClickOnOrganicRec")
                    self.errorReporter?.setMessage(message: errorMsg).reportErrorToServer()
                    return
                }
                
                if let orgRecURL = URL(string: orgUrl) {
                    DispatchQueue.main.async {
                        let orgClickImplemented = self.delegate?.onOrganicRecClick != nil
                        orgClickImplemented ? self.delegate?.onOrganicRecClick!(orgRecURL) : self.delegate?.onRecClick(recURL)
                    }

                    return
                }
                
                DispatchQueue.main.async {
                    self.delegate?.onRecClick(recURL)
                }
            }
        }
    }

    func clickOpenRequest(for url: URL, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url) { (_, response, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode {
                completionHandler(.success(()))
                return
            }
            
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            let error = NSError(domain: "", code: statusCode, userInfo: nil)
            completionHandler(.failure(error))
            
        }
        dataTask.resume()
    }

    public func onRecClick(_ url: URL) {
        self.delegate?.onRecClick(url)
    }
    
    public func onSettingsReceived(_ settings: [String : Any]) {
        self.settings = settings
    }
}

// MARK: WKUIDelegate
extension SFWidget: WKUIDelegate, WKNavigationDelegate {
    private func isDisplaySettingEnabled() -> Bool {
        guard let flagSetting = self.settings["shouldEnableBridgeDisplay"] as? Bool else {
            return false
        }
        
        return flagSetting == true
    }
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                self.delegate?.onRecClick(url)
            }
        }
        return nil
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard isDisplaySettingEnabled(),
              let url = navigationAction.request.url,
              UIApplication.shared.canOpenURL(url) else {
            decisionHandler(.allow)
            return
        }
        
        if let targetFrame = navigationAction.targetFrame,
           targetFrame.isMainFrame == true,
           navigationAction.sourceFrame.isMainFrame == false,
           url.absoluteString.contains("widgets.outbrain.com/reactNativeBridge") == false {
            decisionHandler(.cancel)
            self.delegate?.onRecClick(url)
            return
        }
        
        decisionHandler(.allow)
    }
}
