//
//  OBRecommendation.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 19/06/2023.
//

import Foundation

public struct OBRecommendation {
    
    public var url: String? // click url of the recommendation
    public var origUrl: String? // original click url of the recommendation
    public var content: String? // title
    public var source: String? // source
    public var image: OBImageInfo? // image
    public var position: String? // position
    public var author: String? // doc author
    public var publishDate: Date? // doc publish date
    public var sameSource: Bool? // is same source
    public var disclosure: OBDisclosure? // disclosure object
    public var pixels: [String]? // pixels to fire
    public var reqId: String? // request id, used for viewability loggin
    
    // check if the recommendation is a paid link
    public var isPaidLink: Bool { return url!.contains("paid.outbrain.com") }
    
    // check if the recommendation is a RTB ad
    public var isRTB: Bool { return shouldDisplayDisclosureIcon() }
    public var isVideo: Bool { return false }

    // check if should display disclosure icon
    public func shouldDisplayDisclosureIcon() -> Bool {
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
        self.sameSource = sameSource
        self.disclosure = disclosure
        self.pixels = pixels
    }
}
