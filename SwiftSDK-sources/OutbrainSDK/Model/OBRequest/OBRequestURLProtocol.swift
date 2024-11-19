//
//  OBRequestURLProtocol.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 04/11/2024.
//


protocol OBRequestURLProtocol {
    
    var base: String { get }
    
    
    func toComponents() -> URLComponents
}

extension OBRequestURLProtocol {
    
    func toComponents() -> URLComponents {
        URLComponents(string: base)!
    }
}


struct OBRequestURLs: OBRequestURLProtocol {
    
    var base: String {
        get {
            if OBAppleAdIdUtil.isOptedOut {
                "https://mv.outbrain.com/Multivac/api/get/"
            } else {
                "https://t-mv.outbrain.com/Multivac/api/get/"
            }
        }
    }
}


struct OBPlatformRequestURLs: OBRequestURLProtocol {
    
    var base: String {
        get {
            if OBAppleAdIdUtil.isOptedOut {
                "https://mv.outbrain.com/Multivac/api/platforms/"
            } else {
                "https://t-mv.outbrain.com/Multivac/api/platforms/"
            }
        }
    }
}
