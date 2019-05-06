//
//  DemoResponse.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 1/27/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import Foundation
import Alamofire

final class DemoResponse: ResponseObjectSerializable {
    let status: String
    let count: Int
    var posts : [Post]
    
    init?(response: HTTPURLResponse, representation: Any) {
        guard
            let representation = representation as? [String: Any],
            let status = representation["status"] as? String,
            let count = representation["count"] as? Int,
            let posts = representation["posts"] as? [[String:Any]]
            else { return nil }
        
        self.status = status
        self.count = count
        self.posts = Post.collection(response, representation: posts)
    }
}
