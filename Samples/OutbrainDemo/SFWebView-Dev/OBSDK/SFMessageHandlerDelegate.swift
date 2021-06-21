//
//  SFHeightChangedDelegate.swift
//  OBSDKiOS-SFWidget
//
//  Created by Alon Shprung on 8/11/20.
//  Copyright © 2021 Outbrain inc. All rights reserved.
//


protocol SFMessageHandlerDelegate {
    func didHeightChanged(height: Int);
    func didClickOnRec(url: String);
    func didClickOnOrganicRec(url: String, orgUrl: String);
}
