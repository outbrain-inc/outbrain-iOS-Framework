//
//  ClassicInterstitialVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/31/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "ClassicInterstitialVC.h"
@import SafariServices;

@implementation ClassicInterstitialVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Classic Grid";

    // This is all you have to do for the interstitials
    // Since the requests are controlled within the interstitial themselves
    self.classicInterstitialView.request = [OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID];
    
    // You'll also want to handle the taps
    [self.classicInterstitialView setRecommendationTapHandler:^(OBRecommendation *recommendation) {
        
        // This recommendations was tapped.
        NSURL * url = [Outbrain getUrl:recommendation];
        
        // Now we have a url that we can show in a webview, or if it's a piece of our native content we can decide what to do with it...
        SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
        [self.navigationController presentViewController:sf animated:YES completion:nil];
    }];
}

@end
