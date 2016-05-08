//
//  OBWKWebview.h
//  OutbrainSDK
//
//  Created by Oded Regev on 3/29/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <WebKit/WebKit.h>
@import SafariServices;

@interface OBWKWebview : WKWebView <WKNavigationDelegate, SFSafariViewControllerDelegate>

@end
