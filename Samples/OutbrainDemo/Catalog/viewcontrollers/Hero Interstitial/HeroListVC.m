//
//  HeroListVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/18/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "HeroListVC.h"
@import SafariServices;

@implementation HeroListVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Hero Interstitial";
    
    // Since our interstitials handle loading for us, all we do is set the request properties
    OBRequest * recommendationsRequest = [OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID];
    [self.interstitialView setRequest:recommendationsRequest];
    
    
    // You'll also want to handle the taps
    [self.interstitialView setRecommendationTapHandler:^(OBRecommendation *recommendation) {
        
        // This recommendations was tapped.        
        NSURL * url = [Outbrain getUrl:recommendation];
        
        // Now we have a url that we can show in a webview, or if it's a piece of our native content we can decide what to do with it...
        SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
        [self.navigationController presentViewController:sf animated:YES completion:nil];
    }];
}

@end
