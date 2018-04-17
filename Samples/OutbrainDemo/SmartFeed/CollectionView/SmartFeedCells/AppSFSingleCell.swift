//
//  OutbrainRecCollectionCell.swift
//  ios-SmartFeed
//
//  Created by oded regev on 2/5/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

import UIKit
import OutbrainSDK

class AppSFSingleCell: SFCollectionViewCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
      //  roundCorners()
    }
    
    public func roundCorners() {
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

    }
}
