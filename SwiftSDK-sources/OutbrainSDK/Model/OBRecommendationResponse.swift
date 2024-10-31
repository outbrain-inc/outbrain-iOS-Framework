//
//  Response.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

@objc public class OBRecommendationResponse: NSObject {
    
    @objc public let request: [String: Any] // response request dictionary
    @objc public let settings: [String: Any] // response settings dictionary
    @objc public let viewabilityActions: OBViewabilityActions? // viewability actions urls to fire
    @objc public let recommendations: [OBRecommendation] // array of recommendations
    @objc public var error: OBError? // error object
    
    init(
        request: [String : Any],
        settings: [String : Any],
        viewabilityActions: OBViewabilityActions?,
        recommendations: [OBRecommendation],
        error: OBError? = nil
    ) {
        self.request = request
        self.settings = settings
        self.viewabilityActions = viewabilityActions
        self.recommendations = recommendations
        self.error = error
    }
}
