//
//  SFWidgetTableViewCell.swift
//  OBSDKiOS-SFWidget
//
//  Created by Alon Shprung on 8/10/20.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import WebKit

class SFWidgetTableViewCell : UITableViewCell {
    
    var webview: WKWebView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
