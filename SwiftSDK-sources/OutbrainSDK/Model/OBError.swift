//
//  OBError.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 21/06/2023.
//

import Foundation

public enum OBError: Error {
    
    case generic(message: String?, key: OBErrorsKeys, code: OBErrorCode)
    case network(message: String?, key: OBErrorsKeys, code: OBErrorCode)
    case native(message: String?, key: OBErrorsKeys, code: OBErrorCode)
    case zeroRecommendations(message: String?, key: OBErrorsKeys, code: OBErrorCode)
}


public enum OBErrorsKeys: String {
    
    case generic = "com.outbrain.sdk:OBGenericErrorDomain"
    case network = "com.outbrain.sdk:OBNetworkErrorDomain"
    case native = "com.outbrain.sdk:OBNativeErrorDomain"
    case zeroRecommendations = "com.outbrain.sdk:OBZeroRecommendationseErrorDomain"
}

public enum OBErrorCode: Int {
    
    case generic = 10200
    case parsing = 10201
    case server = 10202
    case invalidParameters = 10203
    case noRecommendations = 10204
    case noData = 10205
}
