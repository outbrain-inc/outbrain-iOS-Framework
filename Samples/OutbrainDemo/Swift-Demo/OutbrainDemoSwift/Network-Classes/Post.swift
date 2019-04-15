//
//  Post.swift
//  OutbrainDemoSwift
//
//  Created by Oded Regev on 1/27/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

import Foundation
import Alamofire


final class Post: ResponseObjectSerializable, CustomStringConvertible {
    let postId: Int
    var date: Date? = nil
    var url: String
    var title: String
    var content: String
    var summary: String
    var author: String = ""
    var imageURL: String = ""
    
    init?(response: HTTPURLResponse, representation: Any) {
        let postData = representation as! [String: Any]
        self.postId = postData["id"] as! Int
        self.title = postData["title"] as! String
        self.content = postData["content"] as! String
        self.summary = postData["excerpt"] as! String
        self.url = postData["url"] as! String
        
        guard let author = postData["author"] as? [String : Any] else {
            return
        }
        
        if let firstName = author["first_name"] as? String, let lastName = author["last_name"] as? String {
            self.author = firstName + lastName
        }
        else {
            self.author = author["nickname"] as! String
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-DD HH:mm:ss"
        self.date = formatter.date(from: postData["date"] as! String)!
        
        if let attachments = postData["attachments"] as? [NSDictionary] {
            if (attachments.count > 0) {
                let firstAttachment = attachments[0]
                let images = firstAttachment["images"] as! [String : Any]
                let fullImage = images["full"] as! [String : Any]
                self.imageURL = fullImage["url"] as! String
            }            
        }
    }
    
    var description : String {
        return "Post #\(self.postId) - \(self.title)\n"
    }
    
    static func collection(_ response: HTTPURLResponse, representation: [[String: Any]]) -> [Post] {
        var posts: [Post] = []

        for postJson in representation {
            if let post = Post(response: response, representation: postJson) {
                posts.append(post)
            }
        }
        
        return posts
    }
}
