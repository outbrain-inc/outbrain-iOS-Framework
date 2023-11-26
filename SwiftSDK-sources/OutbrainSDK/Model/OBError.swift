//
//  OBError.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 21/06/2023.
//

import Foundation

public enum OBError: Error {
    case genericError(message: String?, key: OBErrorsKeys, code: OBErrorCode)
    case networkError(message: String?, key: OBErrorsKeys, code: OBErrorCode)
    case nativeError(message: String?, key: OBErrorsKeys, code: OBErrorCode)
    case zeroRecommendationsError(message: String?, key: OBErrorsKeys, code: OBErrorCode)
}

public enum OBErrorsKeys: String {
    case genericError = "com.outbrain.sdk:OBGenericErrorDomain"
    case networkError = "com.outbrain.sdk:OBNetworkErrorDomain"
    case nativeError = "com.outbrain.sdk:OBNativeErrorDomain"
    case zeroRecommendationsError = "com.outbrain.sdk:OBZeroRecommendationseErrorDomain"
}

public enum OBErrorCode: Int {
    case genericErrorCode = 10200
    case parsingErrorCode = 10201
    case serverErrorCode = 10202
    case invalidParametersErrorCode = 10203
    case noRecommendationsErrorCode = 10204
    case noDataErrorCode = 10205
}
