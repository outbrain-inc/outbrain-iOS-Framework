//
//  Response.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

public struct OBResponse {
    let request: [String: Any] // response request dictionary
    let settings: [String: Any] // response settings dictionary
    let viewabilityActions: OBViewabilityActions? // viewability actions urls to fire
    public let recommendations: [OBRecommendation] // array of recommendations
    public var error: Error? // error object
}
