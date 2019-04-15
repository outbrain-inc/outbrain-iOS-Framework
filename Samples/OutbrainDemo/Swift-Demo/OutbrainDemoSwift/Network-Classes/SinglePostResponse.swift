//
//  SinglePostResponse.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 2/18/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import Foundation
import Alamofire


class SinglePostResponse: ResponseObjectSerializable {
    let status: String
    let post : Post?
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let status = representation["status"] as? String,
            let postJson = representation["post"] as? [String:Any]
            else { return nil }
        
        self.status = status
        self.post = Post(response: response, representation: postJson)
    }
}
