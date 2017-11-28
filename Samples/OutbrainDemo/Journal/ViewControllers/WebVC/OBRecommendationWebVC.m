//
//  OBWebVC.m
//  OutbrainDemo
//
//  Created by Oded Regev on 1/17/14.
//  Copyright (c) 2014 Outbrain inc. All rights reserved.
//

#import "OBRecommendationWebVC.h"
#import <OutbrainSDK/OutbrainSDK.h>

@interface OBRecommendationWebVC ()

@property (nonatomic, strong) WKWebView * wk_WebView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem * backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * refreshButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * forwardButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * actionsButton;

@end


@implementation OBRecommendationWebVC


#pragma mark - View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 20.0, self.view.frame.size.width, self.view.frame.size.height);
    
    self.wk_WebView = [[WKWebView alloc] initWithFrame:frame];
    self.wk_WebView.navigationDelegate = self;
    // KVO on loading
    [self.wk_WebView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:NULL];
    [self.view addSubview:self.wk_WebView];
    
       
    if (self.recommendationUrl)
    {
        [self loadURL:self.recommendationUrl];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

- (void)dealloc
{
    if (self.wk_WebView != nil) {
        [self.wk_WebView removeObserver:self forKeyPath:@"loading"];
    }
}

#pragma mark - User Actions

- (IBAction)optionsAction:(id)sender
{
    UIActivityViewController * vc = [[UIActivityViewController alloc] initWithActivityItems:@[[self getCurrentURL]] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)dismissAction:(id)sender
{
    self.wk_WebView.navigationDelegate = nil;
    [self.wk_WebView stopLoading];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender
{
    [self.wk_WebView goBack];
}


#pragma mark - Helpers

// Our button order is set in the storyboard.
// [Close,FixedSpace,Back,FixedSpace,(optional refresh),FlexSpace,Share]
- (void)_updateButtonStates
{
    self.backButton.enabled = [self.wk_WebView canGoBack];
    self.forwardButton.enabled = [self.wk_WebView canGoForward];
    self.refreshButton.enabled = ![self isWebViewLoading];
    
    [self.wk_WebView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@", ret];
    }];
    
    
    NSInteger activityIndicatorIndex = [self.toolbarItems indexOfObject:self.backButton] + 1;   // Plus 1 because the fixed space is right after
    UIBarButtonItem * activityItem = [self.toolbarItems objectAtIndex:activityIndicatorIndex+1];
    if([self isWebViewLoading] && [activityItem tag] != 100)
    {
        UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indy startAnimating];
        [indy setHidesWhenStopped:YES];
        UIBarButtonItem * loadingItem = [[UIBarButtonItem alloc] initWithCustomView:indy];
        loadingItem.tag = 100;
        NSMutableArray * tmpItems = [[self toolbarItems] mutableCopy];
        [tmpItems insertObject:loadingItem atIndex:activityIndicatorIndex+1];
        [self setToolbarItems:tmpItems animated:YES];
    }
    else if(![self isWebViewLoading] && activityItem.tag == 100)
    {
        NSMutableArray * tmpItems = [[self toolbarItems] mutableCopy];
        [tmpItems removeObject:activityItem];
        [self setToolbarItems:tmpItems animated:YES];
    }
}

- (void) loadURL:(NSURL *)url {
    [self.wk_WebView loadRequest:[NSURLRequest requestWithURL:url]];
}

-(BOOL) isWebViewLoading {
    return self.wk_WebView.isLoading;
}

-(NSURL *) getCurrentURL {
    return self.wk_WebView.URL;
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loading"]) {
        //NSLog(@"isloading? %@" , [self isWebViewLoading] ? @"YES" : @"NO");
    }
}

#pragma mark - WebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateButtonStates) object:nil];
    [self _updateButtonStates];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateButtonStates) object:nil];
    [self _updateButtonStates];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateButtonStates) object:nil];
    // Webview sometimes calls finished when it's really not.  In this
    // case we'll just wait a second to make sure it's actually finished
    [self _updateButtonStates];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self _updateButtonStates];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    [self _updateButtonStates];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [self _updateButtonStates];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

@end
