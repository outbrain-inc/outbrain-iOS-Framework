//
//  SFVideoCollectionViewCell.h
//  OutbrainSDK
//
//  Created by oded regev on 12/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;

@interface SFVideoCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) WKWebView *webview;

@end
