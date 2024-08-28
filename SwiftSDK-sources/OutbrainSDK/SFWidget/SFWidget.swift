//
//  SFWidget.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 25/07/2023.
//

import Foundation
import WebKit


public class SFWidget: UIView {

    public internal(set) var currentHeight: CGFloat = 0
    public var webviewUrl: String?
    var httpHandler: HttpHandler?
    internal var isLoading: Bool = false
    internal var isWidgetEventsEnabled: Bool = false
    internal var inTransition: Bool = false
    internal var url: String?
    internal var widgetId: String?
    internal var installationKey: String?
    internal var userId: String?
    internal var widgetIndex: Int = 0
    internal var isSwiftUI: Bool = false
    internal var tParam: String?
    internal var bridgeParams: String?
    internal var darkMode: Bool = false
    internal weak var delegate: SFWidgetDelegate?
    internal var messageHandler = SFWidgetMessageHandler()
    internal var bridgeUrlBuilder: BridgeUrlBuilder?
    internal var jsExec = JavaScriptExecutor()
    internal var webView: WKWebView?
    internal var hiddenWebView: WKWebView?
    internal var bridgeParamsObserver: NSObjectProtocol?
    internal var tParamObserver: NSObjectProtocol?
    internal var viewabilityTimerHandler = ViewabilityTimerHandler()
    internal var errorReporter: OBErrorReport?
    internal var settings: [String: Any] = [:]
    internal static var isFlutter: Bool = false
    private lazy var swiftUiConfigureDone = false
    internal static var globalBridgeParams: String?
    
    /**
     Indicates that there are multiple widgets on the same content page. Has to be set only when there are multiple widgets on the same page
     */
    public static var infiniteWidgetsOnTheSamePage: Bool = false
    static var isReactNative: Bool = false
    static var flutter_packageVersion: String?
    static var RN_packageVersion: String?

  
    
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
    public func configure(
        with delegate: SFWidgetDelegate,
        url: String,
        widgetId: String,
        installationKey: String
    ) {
        configure(
            with: delegate,
            url: url,
            widgetId: widgetId,
            widgetIndex: 0,
            installationKey: installationKey,
            userId: nil,
            darkMode: false,
            isSwiftUI: false
        )
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
    public func configure(
        with delegate: SFWidgetDelegate,
        url: String,
        widgetId: String,
        widgetIndex: Int,
        installationKey: String,
        userId: String?,
        darkMode: Bool
    ) {
        configure(
            with: delegate,
            url: url,
            widgetId: widgetId,
            widgetIndex: widgetIndex,
            installationKey: installationKey,
            userId: userId,
            darkMode: darkMode,
            isSwiftUI: false
        )
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
    public func configure(
        with delegate: SFWidgetDelegate?,
        url: String,
        widgetId: String,
        installationKey: String
    ) {
        
        if (swiftUiConfigureDone) {
           return
        }

        self.delegate = delegate
        self.url = url
        self.widgetId = widgetId
        self.installationKey = installationKey
        self.errorReporter = OBErrorReport(
            url: url,
            widgetId: widgetId
        )
        
        self.bridgeUrlBuilder = BridgeUrlBuilder(
            url: url,
            widgetId: widgetId,
            installationKey: installationKey
        )
        
        configureBridgeNotificationHandlers()
        
        if widgetIndex > 0 {
            if (SFWidget.globalBridgeParams != nil && SFWidget.infiniteWidgetsOnTheSamePage) {
                // we have the "page context" already from fetching widgetIdx=0 (stored in globalBridgeParams)
                // Therefore, we can load the widget with idx > 0 immediately
                initialLoadUrl()
            } else {
                print("differ fetching until we'll have the \"t\" or \"bridgeParams\" ready")
            }
        } else {
            SFWidget.globalBridgeParams = nil
            initialLoadUrl()
        }
        
        if isSwiftUI == true {
            handleSwiftUI()
            swiftUiConfigureDone = true
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
    public func configure(
        with delegate: SFWidgetDelegate?,
        url: String,
        widgetId: String,
        widgetIndex: Int,
        installationKey: String,
        userId: String?,
        darkMode: Bool,
        isSwiftUI: Bool
    ) {
        self.delegate = delegate
        self.widgetIndex = widgetIndex
        self.darkMode = darkMode
        self.setUserId(userId)
        self.isSwiftUI = isSwiftUI
        
        configure(
            with: delegate,
            url: url,
            widgetId: widgetId,
            installationKey: installationKey
        )
    }
    
    public func setHttpHandler(_ handler: HttpHandler) {
        self.httpHandler = handler
    }
    
    public static func enableFlutterMode(flutter_packageVersion: String) {
        isFlutter = true;
        self.flutter_packageVersion = flutter_packageVersion;
    }
    
    public static func enableReactNativeMode(RN_packageVersion: String) {
        isReactNative = true;
        self.RN_packageVersion = RN_packageVersion;
    }
    
    public static func setInfiniteWidgetsOnTheSamePage(_ infiniteWidgets: Bool) {
        infiniteWidgetsOnTheSamePage = true
    }
    
    public func getCurrentHeight() -> CGFloat {
        return currentHeight
    }
    
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            // The view has been added to a window
            print("View added to window")
            guard !swiftUiConfigureDone else { return }
            handleSwiftUI()
        } else {
            // The view has been removed from a window
            print("View removed from window")
        }
    }
    
    
    func configureBridgeNotificationHandlers() {
        let bridgeParamsNotification = NSNotification.Name(rawValue: SFConsts.SFWIDGET_BRIDGE_PARAMS_NOTIFICATION)
        
        bridgeParamsObserver = NotificationCenter.default.addObserver(
            forName: bridgeParamsNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            Outbrain.logger.log("SFWidget received \"bridgeParams\" notification")
            self?.receiveBridgeParamsNotification(notification)
            
            // Already loaded
            guard self?.widgetIndex != 0 else { return }
            
            DispatchQueue.main.async {
                self?.initialLoadUrl()
            }
        }
    }
    
    
    func receiveBridgeParamsNotification(_ notification: Notification) {
        if notification.name.rawValue == SFConsts.SFWIDGET_BRIDGE_PARAMS_NOTIFICATION {
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
            webView?.isInspectable = inspectable
        }
#endif
    }
    
    
    func setUserId(_ userId: String?) {
#if DEBUG
        if UIDevice.current.model == "Simulator" {
            self.userId = "F22700D5-1D49-42CC-A183-F3676526035F" // dev hack to test Videos
            return
        }
#endif
        
        guard !OBAppleAdIdUtil.isOptedOut else {
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
        if let widgetURL = bridgeUrlBuilder?
            .addPermalink(url: url)
            .addDarkMode(isDarkMode: darkMode)
            .addTParam(tParamValue: tParam)
            .addBridgeParams(bridgeParams: bridgeParams)
            .addEvents(widgetEvents: isWidgetEventsEnabled ? .all : .omit)
            .addExternalId(extId: extId)
            .addExternalSecondaryId(extid2: extSecondaryId)
            .addOBPubImp(pubImpId: OBPubImp)
            .addUserId(userId: userId)
            .addOSTracking()
            .addWidgetIndex(index: widgetIndex)
            .addIsFlutter(isFlutter: SFWidget.isFlutter)
            .addIsReactNative(isReactNative: SFWidget.isReactNative)
            .addFlutterPackageVersion(version: SFWidget.flutter_packageVersion)
            .addReactNativePackageVersion(version: SFWidget.RN_packageVersion)
            .build() {
            
            Outbrain.logger.log("Bridge URL: \(widgetURL)")

            webviewUrl = widgetURL.absoluteString
            
            webView?.load(URLRequest(url: widgetURL))
            webView?.setNeedsLayout()
        }
    }

    
    public func enableEvents() {
        isWidgetEventsEnabled = true
    }
    
    
    // MARK: - Toggle dark mode
    public func toggleDarkMode(_ isDark: Bool) {
        darkMode = isDark
        jsExec.toggleDarkMode(isDark)
    }

    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //check if this check happens from bottom or from bottom view port
        //check if we can move responsebility of load more to js bridge
        viewabilityTimerHandler.handleViewability(
            sfWidget: self,
            containerView: scrollView
        ) { [weak self] viewStatus, width ,height  in
            guard let self else { return }
            
            self.jsExec.setViewData(
                from: viewStatus.visibleFrom,
                to: viewStatus.visibleTo,
                width: width,
                height: height
            )
        }
        
        if isLoading || inTransition || currentHeight <= SFConsts.THRESHOLD_FROM_BOTTOM {
            return
        }

        let contentOffsetY = scrollView.contentOffset.y
        let diffFromBottom = (scrollView.contentSize.height - scrollView.frame.size.height) - contentOffsetY
        
        if diffFromBottom < SFConsts.THRESHOLD_FROM_BOTTOM {
            loadMore()
        }
    }

    
    // this function is used to count a "new" page view on user back action on a specific publisher (bild.de)
    public func reportPageViewOnTheSameWidget() {
        Outbrain.logger.log("Outbrain SDK reportPageViewOnTheSameWidget() is called")
        
        let webviewConf = WKWebViewConfiguration()
        hiddenWebView = WKWebView(
            frame: frame,
            configuration: webviewConf
        )
        
        guard let widgetURL = bridgeUrlBuilder?.addPermalink(url: self.url).build() else { return }
        hiddenWebView?.load(URLRequest(url: widgetURL))
    }
    

    public func loadMore() {
        isLoading = true
        NSLog("loading more --->")
        Outbrain.logger.debug("load-more-recs", domain: "sfWidfet-handler")
        jsExec.loadMore()
        jsExec.evaluateHeight()
    }
    
    
    private func handleSwiftUI() {
        viewabilityTimerHandler.handleSwiftUI(sfWidget: self) { [weak self] viewStatus, width ,height, shouldLoadMore in
            guard let self else { return }
            
            self.jsExec.setViewData(
                from: viewStatus.visibleFrom,
                to: viewStatus.visibleTo,
                width: width,
                height: height
            )
            
            guard shouldLoadMore else { return }
            
            if self.isLoading || self.inTransition || self.currentHeight <= SFConsts.THRESHOLD_FROM_BOTTOM {
                return
            }
            
            self.loadMore()
        }
    }
    
    
    public func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        inTransition = true
        
        // Run after the transition is finished
        coordinator.animate(alongsideTransition: nil) { [weak self] _ in
            self?.jsExec.evaluateHeight()
            self?.inTransition = false
        }
    }

    
    // MARK: - Private
    private func commonInit() {
        configureSFWidget()
        messageHandler.delegate = self
    }
    
    
    func configureSFWidget() {
        guard webView == nil else { return }
        
        let preferences = WKPreferences()
        let webviewConf = WKWebViewConfiguration()
        let jsInitScript = """
            // ReactNativeWebView initialization
            window.ReactNativeWebView = {
                postMessage: function (data) {
                    window.webkit.messageHandlers.ReactNativeWebView.postMessage(String(data));
                }
            };
        """;
        
        let script = WKUserScript(source: jsInitScript, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        let controller = WKUserContentController()
        
        controller.add(messageHandler, name: "ReactNativeWebView")
        controller.addUserScript(script)
        
        webviewConf.userContentController = controller
        webviewConf.allowsInlineMediaPlayback = true
        webviewConf.preferences = preferences
        
        webView = WKWebView(frame: self.frame, configuration: webviewConf)
        webView!.scrollView.isScrollEnabled = false
        webView!.isOpaque = false
        webView!.uiDelegate = self
        webView!.navigationDelegate = self
        setWebViewInspectable(inspectable: SFConsts.isInspectable)
        addSubview(webView!)
        BridgeUtils.addConstraintsToParentView(view: webView!)
        jsExec.setWebView(view: webView!)
        webView!.setNeedsLayout()
    }
}


extension SFWidget: SFMessageHandlerDelegate {
    
    func widgetEvent(eventName: String, additionalData: [String: Any]) {
        if let delegate = self.delegate {
            delegate.widgetEvent?(eventName, additionalData: additionalData)
        }
    }
    
    
    @objc func messageHeightChange(_ height: CGFloat) {
        currentHeight = CGFloat(height)
        
        frame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: frame.size.width,
            height: CGFloat(height)
        )
        
        setNeedsLayout()
        
        delegate?.didChangeHeight?(currentHeight)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.isLoading = false
        }
    }

    
    func didClickOnRec(_ url: String) {
        guard let recURL = URL(string: url) else { return }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.onRecClick(recURL)
        }
    }
    

    func didClickOnOrganicRec(_ url: String, orgUrl: String) {
        guard let recURL = URL(string: url) else { return }
        guard var components = URLComponents(string: url) else { return }
        components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "noRedirect", value: "true")]
        
        guard let trafficURL = components.url else { return }
        clickOpenRequest(for: trafficURL) { result in
            if case .failure(let error) = result {
                let errorMsg = "Error reporting organic click: \(trafficURL), error: \(error)"
                Outbrain.logger.error(errorMsg, domain: "didClickOnOrganicRec")
                self.errorReporter?.setMessage(message: errorMsg).reportErrorToServer()
                return
            }
            
            if let orgRecURL = URL(string: orgUrl) {
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    let orgClickImplemented = self.delegate?.onOrganicRecClick != nil
                    orgClickImplemented ? self.delegate?.onOrganicRecClick!(orgRecURL) : self.delegate?.onRecClick(recURL)
                }
                
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.onRecClick(recURL)
            }
        }
    }
    

    func clickOpenRequest(
        for url: URL,
        completionHandler: @escaping (Result<Void, Error>
        ) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: url) { (_, response, error) in
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
        delegate?.onRecClick(url)
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
    
    
    public func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            delegate?.onRecClick(url)
        }
        
        return nil
    }
    
    
    public func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy
        ) -> Void) {
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
            delegate?.onRecClick(url)
            return
        }
        
        decisionHandler(.allow)
    }
}


// MARK: - UITableView
extension SFWidget {
    
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
}

// MARK: - For Testing
public protocol HttpHandler {
    func handleRequest(_ type:String, request: [String: Any?])
}
