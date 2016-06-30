//
//  OBWKWebview.m
//  OutbrainSDK
//
//  Created by Oded Regev on 3/29/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBWKWebview.h"
#import "Outbrain.h"
#import "CustomWebViewManager.h"

@interface OBWKWebview()

@property (nonatomic, weak) id<WKNavigationDelegate> externalNavigationDelegate;

@property (nonatomic, strong) NSString *paidOutbrainParams;
@property (nonatomic, strong) NSString *paidOutbrainUrl;

@property (nonatomic, assign) BOOL alreadyReportedOnPercentLoad;

@property (nonatomic, strong) NSDate *loadStartDate;

@end


@implementation OBWKWebview


- (instancetype)initWithFrame:(CGRect)frame
                configuration:(WKWebViewConfiguration *)configuration
{
    if (self = [super initWithFrame:frame configuration:configuration]) {
        [super setNavigationDelegate:self];
        [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"estimatedProgress"];
    [super setNavigationDelegate:nil];

}


#pragma mark - Private Methods

-(void) setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate {
    self.externalNavigationDelegate = navigationDelegate;
}




#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"] && object == self) {
        // estimatedProgress is a value from 0.0 to 1.0
        NSLog(@"progress: %f --> %@", self.estimatedProgress, self.URL.host);
        
        if (self.estimatedProgress < 1.0) {
            [[CustomWebViewManager sharedManager] reportOnProgressAndReportIfNeeded:self.estimatedProgress webview:self];
        }
        else if (self.estimatedProgress == 1.0) {
            [[CustomWebViewManager sharedManager] checkUrlAndReportIfNeeded:self];
        }
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
    
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)])
    {
        [self.externalNavigationDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (UIViewController *)parentViewController {
    UIResponder *responder = self;
    while ([responder isKindOfClass:[UIView class]])
        responder = [responder nextResponder];
    return (UIViewController *)responder;
}

/*! @abstract Invoked when a server redirect is received for the main
 frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didReceiveServerRedirectForProvisionalNavigation");
    
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)])
    {
        [self.externalNavigationDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"OB didFailProvisionalNavigation");
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)])
    {
        [self.externalNavigationDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

/*! @abstract Invoked when content starts arriving for the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didCommitNavigation");
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didCommitNavigation:)])
    {
        [self.externalNavigationDelegate webView:webView didCommitNavigation:navigation];
    }
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"OB didFinishNavigation");
    
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didFinishNavigation:)])
    {
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
    NSLog(@"OB didFailNavigation: %@", error.localizedDescription);
    
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)])
    {
        [self.externalNavigationDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

/*! @abstract Decides whether to allow or cancel a navigation.
 @param webView The web view invoking the delegate method.
 @param navigationAction Descriptive information about the action
 triggering the navigation request.
 @param decisionHandler The decision handler to call to allow or cancel the
 navigation. The argument is one of the constants of the enumerated type WKNavigationActionPolicy.
 @discussion If you do not implement this method, the web view will load the request or, if appropriate, forward it to another application.
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)])
    {
        [self.externalNavigationDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

/*! @abstract Invoked when the web view's web content process is terminated.
 @param webView The web view whose underlying web content process was terminated.
 */
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    //NSLog(@"OB didFailNavigation");
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)])
    {
        [self.externalNavigationDelegate webViewWebContentProcessDidTerminate:webView];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    
    //NSLog(@"OB didReceiveAuthenticationChallenge");
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)])
    {
        [self.externalNavigationDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }
    else {
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    //NSLog(@"OB decidePolicyForNavigationResponse");
    
    if (self.externalNavigationDelegate &&
        [self.externalNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)])
    {
        [self.externalNavigationDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }
    else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}


@end
