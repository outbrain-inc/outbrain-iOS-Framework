//
//  OBWKWebview.m
//  OutbrainSDK
//
//  Created by Oded Regev on 3/29/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBWKWebview.h"


@interface OBWKWebview()

@property (nonatomic, weak) id<WKNavigationDelegate> externalNavigationDelegate;

@end


@implementation OBWKWebview

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(WKWebViewConfiguration *)configuration
{
    if (self = [super initWithFrame:frame configuration:configuration]) {
        self.navigationDelegate = self;
    }
    return self;
}

-(void) setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    if (self.navigationDelegate == nil) {
        // SDK delegate from designated initializer
        [super setNavigationDelegate:navigationDelegate];
    }
    else {
        self.externalNavigationDelegate = navigationDelegate;
    }
}


#pragma mark - WKNavigationDelegate


/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didStartProvisionalNavigation");
    if (self.externalNavigationDelegate) {
        [self.externalNavigationDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didReceiveServerRedirectForProvisionalNavigation");
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"OB didFailProvisionalNavigation");
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didCommitNavigation");
    if (self.externalNavigationDelegate) {
        [self.externalNavigationDelegate webView:webView didCommitNavigation:navigation];
    }
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didFinishNavigation");
    if (self.externalNavigationDelegate) {
        [self.externalNavigationDelegate webView:webView didFinishNavigation:navigation];
    }
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"OB didFailNavigation");
}

@end
