//
//  OBRecommendationDelegate.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation


public protocol OBResponseDelegate: AnyObject {
    func outbrainDidReceiveResponse(withSuccess response: OBRecommendationResponse)
}
