//
//  OBWebVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/17/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBRecommendationWebVC.h"
#import <OutbrainSDK/OutbrainSDK.h>

@interface OBRecommendationWebVC ()

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) OBWKWebview * wk_WebView;

@property (nonatomic, weak) IBOutlet UIBarButtonItem * backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * refreshButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * forwardButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem * actionsButton;

@end


#define SYSTEM_VERSION_LESS_THAN(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)


@implementation OBRecommendationWebVC


#pragma mark - View Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 20.0, self.view.frame.size.width, self.view.frame.size.height);
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.webView = [[UIWebView alloc] initWithFrame:frame];
        self.webView.scalesPageToFit = YES;
        [self.webView setTranslatesAutoresizingMaskIntoConstraints: NO];
        self.webView.delegate = self;
        // Fast scrolling
        self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        [self.view addSubview:self.webView];
    }
    else {
        self.wk_WebView = [[OBWKWebview alloc] initWithFrame:frame];
        self.wk_WebView.navigationDelegate = self;
        [self.view addSubview:self.wk_WebView];
    }
    
       
    if(self.recommendation)
    {
        NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:self.recommendation];
        [self loadURL:url];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark - User Actions

- (IBAction)optionsAction:(id)sender
{
    UIActivityViewController * vc = [[UIActivityViewController alloc] initWithActivityItems:@[[self getCurrentURL]] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)dismissAction:(id)sender
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
    self.wk_WebView.navigationDelegate = nil;
    [self.wk_WebView stopLoading];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)goBack:(id)sender
{
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.webView goBack];
    }
    else {
        [self.wk_WebView goBack];
    }
}


#pragma mark - Helpers

// Our button order is set in the storyboard.
// [Close,FixedSpace,Back,FixedSpace,(optional refresh),FlexSpace,Share]
- (void)_updateButtonStates
{
    self.backButton.enabled = SYSTEM_VERSION_LESS_THAN(@"8.0") ? [self.webView canGoBack] : [self.wk_WebView canGoBack];
    self.forwardButton.enabled = SYSTEM_VERSION_LESS_THAN(@"8.0") ? [self.webView canGoForward] : [self.wk_WebView canGoForward];
    self.refreshButton.enabled = ![self isWebViewLoading];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }
    else {
        [self.wk_WebView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            self.navigationItem.title = [NSString stringWithFormat:@"%@", ret];
        }];
    }
    
    
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
//        [tmpItems replaceObjectAtIndex:2 withObject:self.refreshButton];
        [self setToolbarItems:tmpItems animated:YES];
    }
}

- (void) loadURL:(NSURL *)url {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    else {
        [self.wk_WebView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

-(BOOL) isWebViewLoading {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return self.webView.isLoading;
    }
    else {
        return self.wk_WebView.isLoading;
    }
}

-(NSURL *) getCurrentURL {
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        return self.webView.request.URL;
    }
    else {
        return self.wk_WebView.URL;
    }
}

#pragma mark - WebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateButtonStates) object:nil];
//    [self _updateButtonStates];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateButtonStates) object:nil];
    [self _updateButtonStates];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_updateButtonStates) object:nil];
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
    NSLog(@"App didStartProvisionalNavigation");
    [self _updateButtonStates];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"App didFinishNavigation");
    [self _updateButtonStates];
}



@end
