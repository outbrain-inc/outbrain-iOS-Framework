//
//  Response.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

public class OBRecommendationResponse {
    public let request: [String: Any] // response request dictionary
    public let settings: [String: Any] // response settings dictionary
    public let viewabilityActions: OBViewabilityActions? // viewability actions urls to fire
    public let recommendations: [OBRecommendation] // array of recommendations
    public var error: Error? // error object
    
    init(request: [String : Any], settings: [String : Any], viewabilityActions: OBViewabilityActions?, recommendations: [OBRecommendation], error: Error? = nil) {
        self.request = request
        self.settings = settings
        self.viewabilityActions = viewabilityActions
        self.recommendations = recommendations
        self.error = error
    }
}
