//
//  SFWidgetDelegate.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 25/07/2023.
//

import Foundation


@objc public protocol SFWidgetDelegate: AnyObject {
    
    /**
     *  @brief called on recommendation "click" inside the feed. Publisher should open the URL in an external browser.
     *
     *  @param url - the "click URL" of the recommendation, the publisher should open the URL in an external browser.
     */
    func onRecClick(_ url: URL)
    
    /**
     *  @brief (Optional) called when the "feed widget" inside the WebView changed its height. Publisher might want to be notified when the SFWidget changes its height.
     *  @param newHeight - the updated height for the SFWidget
     */
    @objc optional func didChangeHeight(_ newHeight: CGFloat)
    
    /**
     *  @brief (Optional) called when the "feed widget" inside the WebView changed its height. Publisher might want to be notified when the SFWidget changes its height.
     *  @deprecated - please use didChangeHeight:(CGFloat) newHeight
     */
    @available(*, deprecated, message: "Please use didChangeHeight(_ newHeight: CGFloat) instead.")
    @objc optional func didChangeHeight()
    
    /**
     *  @brief (Optional) publisher may choose to "catch" clicks on "organic recommendations" in order to navigate the user to the clicked recommendation INSIDE the app (instead of the default behavior of openning the link in an external browser)
     *
     *  @param url - the organic rec "article url", i.e. the aricle url we should navigate to within the app navigation stack.
     */
    @objc optional func onOrganicRecClick(_ url: URL)
    
    /**
     *  @brief (Optional) called when the JS widget inside the WKWebView dispatch widget events (for example: rendered, error, viewability, etc).
     *      it should be implemented only if the publisher would like to manually keep track of widget events.
     *  @param eventName - the name of the event being dispatched
     *  @param additionalData - additional data that comes with the event. For example you'll find there: "widget ID", "widget index" and "timestamp".
     */
    @objc optional func widgetEvent(_ eventName: String, additionalData: [String: Any])
}
