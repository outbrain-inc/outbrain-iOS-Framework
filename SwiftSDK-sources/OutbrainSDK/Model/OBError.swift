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


@objc public enum OBErrorCode: Int {
    case generic = 10200
    case parsing = 10201
    case server = 10202
    case invalidParameters = 10203
    case noRecommendations = 10204
    case noData = 10205
    case network = 10206
}


@objcMembers public class OBError: NSObject, Error {
    
    public let type: OBErrorType
    public let message: String?
    public let code: OBErrorCode
    
    
    public init(type: OBErrorType, message: String?, code: OBErrorCode) {
        self.type = type
        self.message = message
        self.code = code
    }
    
    public static func generic(message: String?, code: OBErrorCode) -> OBError {
        return OBError(type: .generic, message: message, code: code)
    }
    
    public static func network(message: String?, code: OBErrorCode) -> OBError {
        return OBError(type: .network, message: message, code: code)
    }
    
    public static func native(message: String?, code: OBErrorCode) -> OBError {
        return OBError(type: .native, message: message, code: code)
    }
    
    public static func zeroRecommendations(message: String?, code: OBErrorCode) -> OBError {
        return OBError(type: .zeroRecommendations, message: message, code: code)
    }
}
