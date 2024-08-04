//
//  URLBuilder.swift
//  OutbrainSDK
//
//  Created by Shai Azulay on 26/07/2023.
//

import Foundation
import UIKit


class BridgeUrlBuilder {
    
    private var url: String?
    private var widgetId: String?
    private var installationKey: String?
    private var widgetIndex: String?
    private var usingBundleUrl: String?
    private var usingPortalUrl: String?
    private var lang: String?
    private var tParam: String?
    private var components: URLComponents?
    private var newQueryItems: [URLQueryItem] = []
    private var baseUrl = SFConsts.bridgeUrl
    
    
    init?(
        url: String? = nil,
        widgetId: String? = nil,
        installationKey: String? = nil
    ) {
        guard let url = url,
              let widgetId = widgetId,
              let installationKey = installationKey else {
            print("Error in getSmartfeedUrl() - missing mandatory params")
            return nil
        }
        
        if let customBaseUrl = UserDefaults.standard.value(forKey: "BridgeUrl") as? String {
            baseUrl = customBaseUrl
        }
        
        components = URLComponents(string: baseUrl)
        self.url = url
        self.widgetId = widgetId
        self.installationKey = installationKey
        addImplicitParams()
    }
    
    
    private func addImplicitParams() {
        let appNameStr = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String ?? ""
        newQueryItems.append(URLQueryItem(name: "appName", value: appNameStr))
        
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        newQueryItems.append(URLQueryItem(name: "appBundle", value: bundleIdentifier))
        newQueryItems.append(URLQueryItem(name: "widgetId", value: widgetId))
        newQueryItems.append(URLQueryItem(name: "installationKey", value: installationKey))
        newQueryItems.append(URLQueryItem(name: "platform", value: "ios"))
        newQueryItems.append(URLQueryItem(name: "sdkVersion", value: Outbrain.OB_SDK_VERSION))
        newQueryItems.append(URLQueryItem(name: "inApp", value: "true"))
        newQueryItems.append(URLQueryItem(name: "dosv", value: UIDevice.current.systemVersion))
        newQueryItems.append(URLQueryItem(name: "deviceType", value: DeviceModelUtils.deviceTypeShort))
        newQueryItems.append(URLQueryItem(name: "textSize", value: DeviceModelUtils.isDynamicTextSizeLarge ? "large" : "default")) // text size (Accessibility)
        newQueryItems.append(URLQueryItem(name: "viewData", value: "enabled"))
        
        // GDPR v1
        if let cnsnt  = GDPRUtils.gdprV1ConsentString, !cnsnt.isEmpty {
            newQueryItems.append(URLQueryItem(name: "cnsnt", value:cnsnt))
        }
        
        // GDPR v2
        if let cnsntv2  = GDPRUtils.gdprV2ConsentString, !cnsntv2.isEmpty  {
            newQueryItems.append(URLQueryItem(name: "cnsntv2", value: cnsntv2))
        }
        
        // CCPA
        if let ccpa  = GDPRUtils.ccpaPrivacyString, !ccpa.isEmpty {
            newQueryItems.append(URLQueryItem(name: "ccpa", value: ccpa))
        }
        
        //GPP
        if let gppSections = GPPUtils.gppSections, !gppSections.isEmpty {
            newQueryItems.append(URLQueryItem(name: "gpp_sid", value: gppSections))
        }
        
        //GPP
        if let gppString = GPPUtils.gppString, !gppString.isEmpty {
            newQueryItems.append(URLQueryItem(name: "gpp", value: gppString))
        }
    }
    
    
    func addUserId(userId: String?) -> BridgeUrlBuilder {
        guard let userId = userId else { return self }
        
        newQueryItems.append(URLQueryItem(name: "userId", value: userId))
        return self
    }
    
    func addOSTracking() -> BridgeUrlBuilder {
        newQueryItems.append(
            URLQueryItem(
                name: "ostracking",
                value: !OBAppleAdIdUtil.isOptedOut ? "true" : "false"
            )
        )
        
        return self
    }
    
    func addWidgetIndex(index: Int?) -> BridgeUrlBuilder {
        if let index = index, index > 0 {
            widgetIndex = String(index)
            newQueryItems.append(URLQueryItem(name: "idx", value: self.widgetIndex))
        }
        
        return self
    }
    
    func addPermalink(url: String?) -> BridgeUrlBuilder {
        guard let urlValue = url else { return self }
        
        newQueryItems.append(URLQueryItem(name: "permalink", value: urlValue))
        return self
    }
    
    
    func addTParam(tParamValue: String?) -> BridgeUrlBuilder {
        guard let tParamValue else { return self }
        
        tParam = tParamValue
        newQueryItems.append(URLQueryItem(name: "t", value: tParamValue))
        return self
    }
    
    
    func addBridgeParams(bridgeParams: String?) -> BridgeUrlBuilder {
        if let bp = bridgeParams {
            newQueryItems.append(URLQueryItem(name: "bridgeParams", value: bp))
        }
        
        if let globalBridgeParams = SFWidget.globalBridgeParams, SFWidget.infiniteWidgetsOnTheSamePage {
            newQueryItems.append(URLQueryItem(name: "bridgeParams", value: globalBridgeParams))
        }
        
        return self
    }
    
    
    func addDarkMode(isDarkMode: Bool?) -> BridgeUrlBuilder{
        guard isDarkMode == true else { return self }
        
        newQueryItems.append(URLQueryItem(name: "darkMode", value: "true"))
        return self
    }
    
    
    func addExternalId(extId: String?) -> BridgeUrlBuilder {
        guard let extId = extId else { return self }
        
        newQueryItems.append(URLQueryItem(name: "extid", value: extId))
        return self
    }
    
    
    func addExternalSecondaryId(extid2: String?) -> BridgeUrlBuilder {
        guard let extid2 = extid2 else { return self }
        
        newQueryItems.append(URLQueryItem(name: "extid2", value: extid2))
        return self
    }
    
    
    func addIsFlutter(isFlutter: Bool) -> BridgeUrlBuilder {
        guard isFlutter else { return self }
        
        newQueryItems.append(URLQueryItem(name: "flutter", value: "true"))
        return self
    }
    

    func addFlutterPackageVersion(version: String?) -> BridgeUrlBuilder {
        guard version != nil else { return self }
        newQueryItems.append(URLQueryItem(name: "flutterPackageVersion", value: version))
        return self
    }
    
    func addIsReactNative(isReactNative: Bool) -> BridgeUrlBuilder {
        guard isReactNative else { return self }
        newQueryItems.append(URLQueryItem(name: "reactNative", value: "true"))
        return self
    }
    
    func addReactNativePackageVersion(version: String?) -> BridgeUrlBuilder {
        guard version != nil else { return self }
        newQueryItems.append(URLQueryItem(name: "reactNativePackageVersion", value: version))
        return self
    }
  
    
    func addOBPubImp(pubImpId: String?) -> BridgeUrlBuilder {
        guard let pubImpId = pubImpId else { return self }
        
        newQueryItems.append(URLQueryItem(name: "pubImpId", value: pubImpId))
        return self
    }
    
    
    func addEvents(widgetEvents: WidgetEvents?) -> BridgeUrlBuilder {
        switch widgetEvents {
            case nil, .omit:
                break
            case .testing:
                newQueryItems.append(URLQueryItem(name: "widgetEvents", value: "test"))
            case .all:
                newQueryItems.append(URLQueryItem(name: "widgetEvents", value: "all"))
        }
        
        return self
    }
    
    
    func buildPlatformUrl(for type: PlatformUrlType) -> URL? {
        //how to use: addQueryItems(for: .content(url))
        let errorMsg = "OutbrainSDKError: It seems you set Bridge to run with platform API and did NOT set the mandatory \"lang\" (language) property"
        switch type {
        case .bundle(let url) :
            // first verify that the mandatory param "lang" is set
            guard let lang else {fatalError(errorMsg)}
                
            newQueryItems.append(URLQueryItem(name: "bundleUrl", value: url))
            newQueryItems.append(URLQueryItem(name: "lang", value: lang))
        case .portal(let url):
            guard let lang else {fatalError(errorMsg)}
                
            newQueryItems.append(URLQueryItem(name: "portalUrl", value: url))
            newQueryItems.append(URLQueryItem(name: "lang", value: lang))
        case .content(let url):
            newQueryItems.append(URLQueryItem(name: "contentUrl", value: url))
        }
        
        return build()
    }
    
    
    func build() -> URL? {
        // Remove duplicate query items based on name
        var uniqueQueryItems = [URLQueryItem]()
        var seenQueryItemNames = Set<String>()
        
        newQueryItems.forEach { queryItem in
            if !seenQueryItemNames.contains(queryItem.name) {
                uniqueQueryItems.append(queryItem)
                seenQueryItemNames.insert(queryItem.name)
            }
        }
        
        components?.queryItems = uniqueQueryItems
        return components?.url
    }
}

