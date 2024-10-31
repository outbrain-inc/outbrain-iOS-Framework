//
//  OBRecommendation.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

@objc public class OBRecommendation: NSObject {
    
    @objc public  var url: String? // click url of the recommendation
    @objc public  var origUrl: String? // original click url of the recommendation
    @objc public  var content: String? // title
    @objc public  var source: String? // source
    @objc public  var image: OBImageInfo? // image
    @objc public  var position: String? // position
    @objc public  var author: String? // doc author
    @objc public  var publishDate: Date? // doc publish date
    @objc public  var sameSource: Bool // is same source
    @objc public  var disclosure: OBDisclosure? // disclosure object
    @objc public  var pixels: [String]? // pixels to fire
    @objc public  var reqId: String? // request id, used for viewability loggin
    
    // check if the recommendation is a paid link
    @objc public  var isPaidLink: Bool { return url!.contains("paid.outbrain.com") }
    
    // check if the recommendation is a RTB ad
    @objc public  var isRTB: Bool { return shouldDisplayDisclosureIcon() }
    @objc public  var isVideo: Bool { return false }

    // check if should display disclosure icon
    @objc public  func shouldDisplayDisclosureIcon() -> Bool {
        // Check if both disclosure image and click_url exists
        return disclosure != nil 
        && disclosure!.imageUrl != nil
        && disclosure!.imageUrl!.count > 0
        && disclosure!.clickUrl != nil
        && disclosure!.clickUrl!.count > 0
    }
    
    
    init(
        url: String? = nil,
        origUrl: String? = nil,
        content: String? = nil,
        source: String? = nil,
        image: OBImageInfo? = nil,
        position: String? = nil,
        author: String? = nil,
        publishDate: Date? = nil,
        sameSource: Bool? = nil,
        disclosure: OBDisclosure? = nil,
        pixels: [String]? = nil
    ) {
        self.url = url
        self.origUrl = origUrl
        self.content = content
        self.source = source
        self.image = image
        self.position = position
        self.author = author
        self.publishDate = publishDate
        self.sameSource = sameSource ?? false
        self.disclosure = disclosure
        self.pixels = pixels
    }
}
