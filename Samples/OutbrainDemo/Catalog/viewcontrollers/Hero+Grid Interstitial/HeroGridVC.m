//
//  HeroGridVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/31/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "HeroGridVC.h"

@implementation HeroGridVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Hero grid";

    // This is all you have to do for the interstitials
    // Since the requests are controlled within the interstitial themselves
    self.interstitialView.request = [OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID];

    // You'll also want to handle the taps
    [self.interstitialView setRecommendationTapHandler:^(OBRecommendation *recommendation) {
        // This recommendations was tapped.
        // Here is where we register the click with outbrain for this piece of content
        NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:recommendation];
        
        // Now we have a url that we can show in a webview, or if it's a piece of our native content
        // Then we can inspect [url hash] to get the mobile_id
        
        NSString * message = [NSString stringWithFormat:@"User tapped recommendation.  Need to present content for this url %@", [url absoluteString]];
        
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Recommendation Tapped!" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [a show];
    }];
}
@end
