//
//  SFVideoCollectionViewCell.h
//  OutbrainSDK
//
//  Created by oded regev on 12/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>


@import WebKit;
@class SFItemData;

@interface SFVideoCollectionViewCell : UICollectionViewCell <WKScriptMessageHandler>

@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, weak) SFItemData *sfItem;
@property (nonatomic, weak) UIActivityIndicatorView *spinner;
@end
