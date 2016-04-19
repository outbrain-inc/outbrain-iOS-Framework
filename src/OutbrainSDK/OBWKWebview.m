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

@property (nonatomic, strong) NSString *paidOutbrainParams;

@end


@implementation OBWKWebview

- (instancetype)initWithFrame:(CGRect)frame
                configuration:(WKWebViewConfiguration *)configuration
{
    if (self = [super initWithFrame:frame configuration:configuration]) {
        self.navigationDelegate = self;
        [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"estimatedProgress"];
    [self setNavigationDelegate:nil];

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


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self) {
        NSLog(@"progress: %f", self.estimatedProgress);
        // estimatedProgress is a value from 0.0 to 1.0
        // Update your UI here accordingly
    }
    else {
        // Make sure to call the superclass's implementation in the else block in case it is also implementing KVO
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
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
    
    if ([[webView.URL absoluteString] containsString:@"paid.outbrain.com"]) {
        NSArray *components = [[webView.URL absoluteString] componentsSeparatedByString:@"?"];
        if (components.count == 2) {
            self.paidOutbrainParams = components[1];
        }
    }
    
    NSString *tempUrl = [webView.URL absoluteString];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if ([[webView.URL absoluteString] isEqualToString:tempUrl]) {
            NSLog(@"** Real Pageview: %@ **", tempUrl);
            
            if (self.paidOutbrainParams != nil)  NSLog(@"** params: %@ **", self.paidOutbrainParams);
        }
    });
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
