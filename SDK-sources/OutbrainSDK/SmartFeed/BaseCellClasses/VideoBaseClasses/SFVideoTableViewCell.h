//
//  SFVideoTableViewCell.h
//  OutbrainSDK
//
//  Created by oded regev on 25/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFTableViewCell.h"
#import "SFUtils.h"

@import WebKit;
@class SFItemData;


@interface SFVideoTableViewCell : SFTableViewCell <WKScriptMessageHandler, SFVideoCellType>

@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, strong) SFItemData *sfItem;

@end
