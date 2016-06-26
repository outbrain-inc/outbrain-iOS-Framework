//
//  OBWebView.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/23/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBWebView.h"
#import "CustomWebViewManager.h"
#import "NJKWebViewProgress.h"

@interface OBWebView()

@property (nonatomic, weak) id<UIWebViewDelegate> externalDelegate;

@property (nonatomic, strong) NJKWebViewProgress *progressProxy;

@end




@implementation OBWebView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.progressProxy = [[NJKWebViewProgress alloc] init];
        
        [super setDelegate:self.progressProxy]; // Pass Webview delegate calls to progressProxy
        
        self.progressProxy.webViewProxyDelegate = self; // progressProxy will pass UIWebViewDelegate delegate calls back to original delegate after handling the calls itself.
        
        self.progressProxy.progressDelegate = (id<NJKWebViewProgressDelegate>)self; // Receive the progress status from the progressProxy
    }
    return self;
}

- (void)dealloc
{
    [super setDelegate:nil];
}

-(void) setDelegate:(id<UIWebViewDelegate>)delegate {
    self.externalDelegate = delegate;
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    NSLog(@"** progress: %f --> %@ **", progress, self.request.URL.host);
    
    if (progress < 1.0) {
        [[CustomWebViewManager sharedManager] reportOnProgressAndReportIfNeeded:progress webview:self];
    }
    else if (progress == 1.0) {
        [[CustomWebViewManager sharedManager] checkUrlAndReportIfNeeded:self];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (self.externalDelegate &&
        [self.externalDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
    {
        return [self.externalDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.externalDelegate &&
        [self.externalDelegate respondsToSelector:@selector(webViewDidStartLoad:)])
    {
        [self.externalDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if (self.externalDelegate &&
        [self.externalDelegate respondsToSelector:@selector(webViewDidFinishLoad:)])
    {
        [self.externalDelegate webViewDidFinishLoad:webView];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    if (self.externalDelegate &&
        [self.externalDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
    {
        [self.externalDelegate webView:webView didFailLoadWithError:error];
    }
}



@end
