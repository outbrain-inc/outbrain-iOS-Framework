//
//  SFHorizontalWithVideoCollectionViewCell.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHorizontalView.h"
#import "SFHorizontalCollectionViewCell.h"

@import WebKit;
@class SFItemData;


@interface SFHorizontalWithVideoCollectionViewCell : SFHorizontalCollectionViewCell <WKScriptMessageHandler>

@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, strong) SFItemData *sfItem;

@end
