//
//  SFWidgetDelegate.swift
//  OBSDKiOS-SFWidget
//
//  Created by Alon Shprung on 8/11/20.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//

import WebKit

@objc protocol SFWidgetDelegate {
    
    func didChangeHeight();
    
    func onRecClick(url: URL);
    
    @objc optional func onOrganicRecClick(url: URL);
}
