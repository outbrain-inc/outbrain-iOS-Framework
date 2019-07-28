//
//  OBDataHelper.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 1/24/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import Foundation
import Alamofire
import OutbrainSDK


class OBNetworkManager {
    static let sharedInstance = OBNetworkManager()
    static let kOB_DEMO_WIDGET_ID = "SDK_2"
    
    func loadPostsFromServer(_ completion: ((_ posts: [Post]?, _ error: NSError?) -> Void)!) {
        let url = "http://mobile-demo.outbrain.com/?json=true"
        
        _ = Alamofire.request(url).responseObject(completionHandler: { (response: DataResponse<DemoResponse>) in
            if let demoResponse = response.result.value {                
                completion?(demoResponse.posts, nil)
            }
            else if response.result.isFailure {
                completion?(nil, response.result.error as NSError?)
            }
            else {
                completion(nil, NSError(domain: "Posts Response Error", code: (response.response?.statusCode)!, userInfo: nil))
            }
        })
    }
    
    func loadSinglePostDataFromServer(_ postUrl:String, completion: ((_ post: Post?, _ error: NSError?) -> Void)!) {
        let url = postUrl + "?json=true"
        
        _ = Alamofire.request(url).responseObject(completionHandler: { (response: DataResponse<SinglePostResponse>) in
            if let singlePostResponse = response.result.value {
                completion?(singlePostResponse.post, nil)
            }
            else if response.result.isFailure {
                completion?(nil, response.result.error as NSError?)
            }
            else {
                completion(nil, NSError(domain: "Post Response Error", code: (response.response?.statusCode)!, userInfo: nil))
            }
        })
    }
    
    func fetchOutbrainRecommendations(_ url:String, completion: @escaping (_ recs: [OBRecommendation]?) -> Void) {
        let request = OBRequest(url: url, widgetID: OBNetworkManager.kOB_DEMO_WIDGET_ID, widgetIndex: 0)
        Outbrain.fetchRecommendations(for: request) { response in
            completion(response?.recommendations as? [OBRecommendation])
        }    
    }
}

extension String {
    
    var stringByStrippingHTML: String {
        var string = self
        let charactersToReplace = ["<br>", "<br />", "<br/>", "</p>"]
        
        for charater in charactersToReplace {
            string = string.replacingOccurrences(of: charater, with: "\n")
        }
        
        while let range = string.range(of: "<[^>]+>", options: .regularExpression, range: nil, locale: nil) {
            string = string.replacingCharacters(in: range, with: "")
        }
        
        string = string.replacingOccurrences(of: "\n\n", with: "\n")
        string = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return string
    }
}
