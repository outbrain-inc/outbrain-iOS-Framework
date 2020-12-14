//
//  AppSFCollectionViewReadMoreCell.swift
//  OutbrainDemo
//
//  Created by Alon Shprung on 30/11/2020.
//  Copyright © 2020 Outbrain inc. All rights reserved.
//

import UIKit
import OutbrainSDK

class AppSFCollectionViewReadMoreCell: SFCollectionViewReadMoreCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.readMoreLabel.layer.borderColor = UIColor.red.cgColor
    }
}
