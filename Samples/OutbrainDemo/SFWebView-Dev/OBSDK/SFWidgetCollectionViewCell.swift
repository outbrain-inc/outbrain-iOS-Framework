//
//  SFWidgetCollectionViewCell.swift
//  OBSDKiOS-SFWidget
//
//  Created by Alon Shprung on 8/10/20.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import WebKit

class SFWidgetCollectionViewCell : UICollectionViewCell {
    
    var webview: WKWebView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}
