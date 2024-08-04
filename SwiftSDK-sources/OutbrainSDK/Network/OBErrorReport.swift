//
//  OBErrorReport.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 29/06/2023.
//

import Foundation
import UIKit

public struct OBErrorReport {
    var errorMessage: String?
    var widgetId: String?
    var odbRequestUrlParamValue: String?
    var sourceId: String?
    var publisherId: String?
    
    static var shared = OBErrorReport()
    
    private init(errorMessage: String? = nil, widgetId: String? = nil, odbRequestUrlParamValue: String? = nil, sourceId: String? = nil, publisherId: String? = nil) {
        self.errorMessage = errorMessage
        self.widgetId = widgetId
        self.odbRequestUrlParamValue = odbRequestUrlParamValue
        self.sourceId = sourceId
        self.publisherId = publisherId
    }
    
    public init(url: String?, widgetId: String?) {
        if let url = url{
            self.odbRequestUrlParamValue = url
        }
        
        if let widgetId = widgetId {
            self.widgetId = widgetId
        }
    }
    
    mutating func setMessage(message: String?) -> OBErrorReport {
        if let message = message {
            self.errorMessage = message
        }
        
        return self
    }
    
    mutating func resetReport() {
        self.errorMessage = nil
        self.widgetId = nil
        self.odbRequestUrlParamValue = nil
        self.sourceId = nil
        self.publisherId = nil
    }
    
    // generate the url for the widgetmonitor
    func errorReportURL() -> URL? {
        var odbQueryItems = [URLQueryItem]()
        var components = URLComponents(string: OB_ERROR_REPORT_CONSTANTS.WIDGET_MONITOR_ENDPOINT)
        
        // Event Name for SDK error
        odbQueryItems.append(URLQueryItem(name: "name", value: OB_ERROR_REPORT_CONSTANTS.ERROR_TYPE_NAME))
        
        var extraParams: [String: Any] = [:]
        
        // Partner Key
        let partnerKey = Outbrain.partnerKey
        extraParams["partnerKey"] = partnerKey ?? "null"
        
        // WidgetId
        extraParams["widgetId"] = self.widgetId
        
        // SDK Version
        extraParams["sdk_version"] = Outbrain.OB_SDK_VERSION
        
        // Device model
        extraParams["dm"] = DeviceModelUtils.deviceModel
        
        // App Version
        let appVersionString = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        extraParams["app_ver"] = appVersionString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // OS version
        extraParams["dosv"] = UIDevice.current.systemVersion
        
        // Random
        let randInteger = Int(arc4random()) % 10000
        let randNumStr = String(randInteger)
        extraParams["rand"] = randNumStr
        
        // JSON Serialization
        if JSONSerialization.isValidJSONObject(extraParams) {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: extraParams, options: .prettyPrinted)
                if let jsonString = String(data: jsonData, encoding: .utf8) {
                    odbQueryItems.append(URLQueryItem(name: "extra", value: jsonString))
                }
            } catch {
                print("JSONSerialization error: \(error)")
            }
        }
        
        // SID, PID, URL
        if let odbRequestUrlParamValue = self.odbRequestUrlParamValue {
            odbQueryItems.append(URLQueryItem(name: "url", value: odbRequestUrlParamValue))
        }
        else {
            odbQueryItems.append(URLQueryItem(name: "url", value: "https://www.outbrain.com")) // Must have a default value
        }
        if let sourceId = self.sourceId {
            odbQueryItems.append(URLQueryItem(name: "sId", value: sourceId))
        }
        if let publisherId = self.publisherId {
            odbQueryItems.append(URLQueryItem(name: "pId", value: publisherId))
        }
        
        // Error Message
        odbQueryItems.append(URLQueryItem(name: "message", value: errorMessage ))
        components?.queryItems = odbQueryItems
        
        if let url = components?.url {
            Outbrain.logger.debug("widget monitor error reporting - \(url.absoluteString)")
            return url
        }
        
        return nil
    }
    
    // report the error to the widgetmonitor
    func reportErrorToServer() {
        // build url to report error
        guard let url = errorReportURL() else {
            return
        }
                
        // call the widgetmonitor with the error payload
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                Outbrain.logger.error("widget monitor error reporting - error: \(error)")
            }
        }
        task.resume()
    }
}

enum OB_ERROR_REPORT_CONSTANTS {
    static let WIDGET_MONITOR_ENDPOINT = "https://widgetmonitor.outbrain.com/WidgetErrorMonitor/api/report"
    static let ERROR_TYPE_NAME = "IOS_SDK_ERROR"
}
