//
//  OBRecommendationDelegate.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation


@objc public protocol OBResponseDelegate: AnyObject {
    
    func outbrainDidReceiveResponse(withSuccess response: OBRecommendationResponse)
    
    func outbrainFailedToReceiveResposne(withError error: OBError?)
}
