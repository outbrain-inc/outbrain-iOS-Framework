//
//  OBRecImage.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 20/06/2023.
//

import Foundation

@objc public class OBImageInfo: NSObject {
    
    @objc public let width: Int
    @objc public let height: Int
    @objc public let url: URL?
    
    init(width: Int, height: Int, url: URL?) {
        self.width = width
        self.height = height
        self.url = url
    }
}
