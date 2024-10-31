//
//  OBError.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 21/06/2023.
//
import Foundation

@objc public enum OBErrorType: Int {
    case generic = 0
    case network
    case native
    case zeroRecommendations
}

@objc public enum OBErrorsKeys: Int {
    case generic = 0
    case network
    case native
    case zeroRecommendations
    
    public var domain: String {
        switch self {
        case .generic:
            return "com.outbrain.sdk:OBGenericErrorDomain"
        case .network:
            return "com.outbrain.sdk:OBNetworkErrorDomain"
        case .native:
            return "com.outbrain.sdk:OBNativeErrorDomain"
        case .zeroRecommendations:
            return "com.outbrain.sdk:OBZeroRecommendationseErrorDomain"
        }
    }
}

@objc public enum OBErrorCode: Int {
    case generic = 10200
    case parsing = 10201
    case server = 10202
    case invalidParameters = 10203
    case noRecommendations = 10204
    case noData = 10205
}

@objc public class OBError: NSObject {
    @objc public let type: OBErrorType
    @objc public let message: String?
    @objc public let key: OBErrorsKeys
    @objc public let code: OBErrorCode

    @objc public init(type: OBErrorType, message: String?, key: OBErrorsKeys, code: OBErrorCode) {
        self.type = type
        self.message = message
        self.key = key
        self.code = code
    }

    @objc public static func genericError(message: String?, key: OBErrorsKeys, code: OBErrorCode) -> OBError {
        return OBError(type: .generic, message: message, key: key, code: code)
    }

    @objc public static func networkError(message: String?, key: OBErrorsKeys, code: OBErrorCode) -> OBError {
        return OBError(type: .network, message: message, key: key, code: code)
    }

    @objc public static func nativeError(message: String?, key: OBErrorsKeys, code: OBErrorCode) -> OBError {
        return OBError(type: .native, message: message, key: key, code: code)
    }

    @objc public static func zeroRecommendationsError(message: String?, key: OBErrorsKeys, code: OBErrorCode) -> OBError {
        return OBError(type: .zeroRecommendations, message: message, key: key, code: code)
    }
}
