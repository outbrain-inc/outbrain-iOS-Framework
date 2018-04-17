//
//  AppSFHorizontalItemCell.swift
//  ios-SmartFeed
//
//  Created by oded regev on 14/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import Foundation
import UIKit

import OutbrainSDK

class AppSFHorizontalItemCell: SFCollectionViewCell {
    
    override func prepareForReuse() {
        self.recImageView.image = nil
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 8 // optional
    }
}
