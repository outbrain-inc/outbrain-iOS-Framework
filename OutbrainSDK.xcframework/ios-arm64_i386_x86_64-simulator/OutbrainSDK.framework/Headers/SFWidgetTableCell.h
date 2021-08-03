//
//  SFWidgetTableCell.h
//  OutbrainSDK
//
//  Created by Oded Regev on 27/06/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SFWidgetTableCell : UITableViewCell

@property (nonatomic, strong) WKWebView *webview;

@end

NS_ASSUME_NONNULL_END
