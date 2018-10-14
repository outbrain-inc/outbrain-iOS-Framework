//
//  SFHorizontalWithVideoTableViewCell.h
//  OutbrainSDK
//
//  Created by oded regev on 14/10/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHorizontalView.h"
#import "SFHorizontalTableViewCell.h"
#import "SFUtils.h"
#import "SFScriptMessageHandler.h"

@import WebKit;
@class SFItemData;


@interface SFHorizontalWithVideoTableViewCell : SFHorizontalTableViewCell <SFVideoCellType>

@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, strong) SFItemData *sfItem;
@property (nonatomic, strong, readonly) SFScriptMessageHandler *wkScriptMessageHandler;

@end
