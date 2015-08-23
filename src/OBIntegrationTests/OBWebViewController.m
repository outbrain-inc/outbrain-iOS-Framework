//
//  OBWebViewController.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/30/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBWebViewController.h"
#import "OutbrainSDK.h"
#import "OBRecommendationResponse.h"

#import "OBReccomendationResponseListVC.h"

@interface OBWebViewController () <UIWebViewDelegate>
@end

@implementation OBWebViewController


#pragma mark - View Cycle

- (void)loadView
{
    UIView *v = [[UIView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    v.backgroundColor = [UIColor whiteColor];
    
    
    UIWebView * wv = [[UIWebView alloc] initWithFrame:v.bounds];
    wv.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    wv.delegate = self;
    [v addSubview:wv];
    self.webView = wv;
    
    self.view = v;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Outbrain Demo";
    
    NSString * url = [[NSUserDefaults standardUserDefaults] valueForKey:@"ob_base_url"];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Fetch" style:UIBarButtonItemStyleBordered target:self action:@selector(obFetch)];
    
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:_webView action:@selector(goBack)],
                          flex,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:_webView action:@selector(reload)],
                          flex,
                          [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:_webView action:@selector(goForward)]
                          ];
}


#pragma mark - Actions

- (void)obFetch
{
    // Here we should fetch some recommendations for the current web page link
    typeof(self) __weak __self = self;
    NSString * widgetID = [[NSUserDefaults standardUserDefaults] valueForKey:@"ob_widget_id"]; // from settings bundle
    OBRequest * request = [OBRequest requestWithURL:[_webView.request.URL absoluteString] widgetID:widgetID];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        // Got response
        dispatch_async(dispatch_get_main_queue(), ^{
           if(response.error)
           {
               // Got an error.  Let's show it
               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:response.error.domain message:response.error.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
               [alert show];
           } else {
               if(response.recommendations.count == 0)
               {
                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:[NSString stringWithFormat:@"Got 0 recommendations for url %@",__self.webView.request.URL.absoluteString] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                   [alert show];
               } else {
                   [__self showResponse:response];
               }
           }
        });
    }];
}

- (void)showResponse:(OBRecommendationResponse *)response
{
    OBReccomendationResponseListVC * responseListVC = [[OBReccomendationResponseListVC alloc] initWithStyle:UITableViewStylePlain];
    responseListVC.recommendationResponse = response;
    responseListVC.title = [NSString stringWithFormat:@"%lu Recommendations", (unsigned long)response.recommendations.count];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:responseListVC];
    [self presentViewController:nav animated:YES completion:nil];
}


#pragma mark - UIWebView Delegate

- (void)_checkWebNavButtons
{
    // Here we want to check if we can goback/forward, and enable/disable the buttons respectively
    UIBarButtonItem *back = self.toolbarItems[0];
    UIBarButtonItem *forward = [self.toolbarItems lastObject];
    
    [back setEnabled:[_webView canGoBack]];
    [forward setEnabled:[_webView canGoForward]];
    
    // Now let's set the title
    NSString * title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if(title && title.length > 0)
    {
        [self.navigationItem setTitle:title];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self _checkWebNavButtons];
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self _checkWebNavButtons];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self _checkWebNavButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self _checkWebNavButtons];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
