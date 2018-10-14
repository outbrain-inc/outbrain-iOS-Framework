//
//  SFVideoCollectionViewCell.h
//  OutbrainSDK
//
//  Created by oded regev on 12/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFCollectionViewCell.h"
#import "SFUtils.h"
#import "SFScriptMessageHandler.h"

@import WebKit;
@class SFItemData;


@interface SFVideoCollectionViewCell : SFCollectionViewCell <SFVideoCellType>

@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, strong) SFItemData *sfItem;
@property (nonatomic, strong, readonly) SFScriptMessageHandler *wkScriptMessageHandler;
@end
