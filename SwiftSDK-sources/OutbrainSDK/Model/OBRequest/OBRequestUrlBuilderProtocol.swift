//
//  OBRequestUrlBuilderProtocol.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 11/11/2024.
//

import UIKit


protocol OBRequestUrlBuilderProtocol {
    
    var request: OBRequest { get }
    
    var urls: OBRequestURLProtocol { get }
    
    
    func buildOdbParams() -> URLComponents?
}



extension OBRequestUrlBuilderProtocol {
    
    
    func buildOdbParams() -> URLComponents? {
        var reqComponents = urls.toComponents()
        var queryItems = buildDefaultQueryItems()
        
        // add platforms params if needed or just the url if regular call
        if !request.isPlatformsRequest {
            queryItems.append(addReqParam(name: "url", value: request.url))
        }
        
        // add test mode
        if Outbrain.testMode {
            queryItems.append(addReqParam(name: "testMode", value: "true"))
            
            if Outbrain.testRTB {
                queryItems.append(URLQueryItem(name: "fakeRec", value: "RTB"))
                queryItems.append(URLQueryItem(name: "fakeRecSize", value: "2"))
                queryItems.append(URLQueryItem(name: "rtbEnabled", value: "true"))
            }
            
            if Outbrain.testLocation != nil {
                queryItems.append(URLQueryItem(name: "location", value: Outbrain.testLocation))
            }
        }
        
        
        reqComponents.queryItems = queryItems.compactMap { $0 }
        return reqComponents
    }
    
    
    func buildDefaultQueryItems() -> [URLQueryItem?] {
        let queryItems = [
            addReqParam(name: "key", value: Outbrain.partnerKey),
            addReqParam(name: "version", value: Outbrain.OB_SDK_VERSION),
            addReqParam(name: "app_ver", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""),
            addReqParam(name: "rand", value: String(describing: Int.random(in: 0..<10000))),
            addReqParam(name: "widgetJSId", value: request.widgetId),
            addReqParam(name: "idx", value: "\(request.widgetIndex)"),
            addReqParam(name: "format", value: "vjnc"),
            addReqParam(name: "api_user_id", value: OBRequestHandler.getApiUserId()),
            addReqParam(name: "installationType", value: "ios_sdk"),
            addReqParam(name: "rtbEnabled", value: "true"),
            addReqParam(name: "sk_network_version", value: OBRequestHandler.getSkNetworkVersion()),
            addReqParam(name: "app_id", value: Bundle.main.bundleIdentifier),
            addReqParam(name: "doo", value: OBRequestHandler.getOptedOut() ? "true" : "false"),
            addReqParam(name: "dos", value: "ios"),
            addReqParam(name: "platform", value: "ios"),
            addReqParam(name: "dosv", value: UIDevice.current.systemVersion),
            addReqParam(name: "dm", value: DeviceModelUtils.deviceModel),
            addReqParam(name: "deviceType", value: DeviceModelUtils.deviceTypeShort),
            addReqParam(name: "va", value: "true"),
            addReqParam(name: "t", value: getTParam()),
            addReqParam(name: "apv", value: getApvParam()),
            addReqParam(name: "secured", value: "true"),
            addReqParam(name: "ref", value: "https://app-sdk.outbrain.com/"),
            addReqParam(name: "extid", value: request.externalID),
            addReqParam(name: "cnsnt", value: GDPRUtils.gdprV1ConsentString ?? ""),
            addReqParam(name: "cnsntv2", value: GDPRUtils.gdprV2ConsentString ?? ""),
            addReqParam(name: "ccpa", value: GDPRUtils.ccpaPrivacyString ?? ""),
            addReqParam(name: "gpp_sid", value: GPPUtils.gppSections ?? ""),
            addReqParam(name: "gpp", value: GPPUtils.gppString ?? ""),
            addReqParam(name: "ostracking", value: !OBAppleAdIdUtil.isOptedOut ? "true" : "false"),
            addReqParam(name: "clientType", value: "10")
        ]
        
        return queryItems
    }
    
    
    func getTParam() -> String? {
        guard request.widgetIndex > 0, let tParam = Outbrain.lastTParam else { return nil }
        return tParam
    }
    
    
    func getApvParam() -> String? {
        return Outbrain.lastApvParam == true ? "true" : nil
    }
    
    
    func addReqParam(name: String, value: String?) -> URLQueryItem? {
        if value == nil || value!.isEmpty {
            return nil
        }
        
        return URLQueryItem(name: name, value: value!)
    }
}
