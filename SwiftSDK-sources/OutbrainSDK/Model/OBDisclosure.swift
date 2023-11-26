//
//  OBDisclosure.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 27/06/2023.
//

import Foundation

public struct OBDisclosure {
    var imageUrl: String? // disclosure image url
    var clickUrl: String? // disclosure click url
    
    init(imageUrl: String? = nil, clickUrl: String? = nil) {
        self.imageUrl = imageUrl
        self.clickUrl = clickUrl
    }
}
