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
@property (nonatomic, weak, readwrite) IBOutlet UIWebView * webView;

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
    
    if(self.recommendation)
    {
        NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:self.recommendation];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    self.webView.suppressesIncrementalRendering = YES;
    // Fast scrolling
    self.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
}

#pragma mark - User Actions

- (IBAction)optionsAction:(id)sender
{
    UIActivityViewController * vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.request.URL] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)dismissAction:(id)sender
{
    self.webView.delegate = nil;
    [self.webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Helpers

// Our button order is set in the storyboard.
// [Close,FixedSpace,Back,FixedSpace,(optional refresh),FlexSpace,Share]
- (void)_updateButtonStates
{
    self.backButton.enabled = [self.webView canGoBack];
    self.forwardButton.enabled = [self.webView canGoForward];
    self.refreshButton.enabled = ![self.webView isLoading];
    
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    NSInteger activityIndicatorIndex = [self.toolbarItems indexOfObject:self.backButton] + 1;   // Plus 1 because the fixed space is right after
    UIBarButtonItem * activityItem = [self.toolbarItems objectAtIndex:activityIndicatorIndex+1];
    if([self.webView isLoading] && [activityItem tag] != 100)
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
    else if(![self.webView isLoading] && activityItem.tag == 100)
    {
        NSMutableArray * tmpItems = [[self toolbarItems] mutableCopy];
        [tmpItems removeObject:activityItem];
//        [tmpItems replaceObjectAtIndex:2 withObject:self.refreshButton];
        [self setToolbarItems:tmpItems animated:YES];
    }
}


#pragma mark - WebView

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

@end
