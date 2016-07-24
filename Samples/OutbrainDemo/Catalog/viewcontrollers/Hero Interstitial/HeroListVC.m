//
//  HeroListVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/18/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "HeroListVC.h"

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
        
        // Now we have a url that we can show in a webview, or if it's a piece of our native content
        // Then we can inspect [url hash] to get the mobile_id
        
        NSString * message = [NSString stringWithFormat:@"User tapped recommendation.  Need to present content for this url %@", [url absoluteString]];
        
        UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Recommendation Tapped!" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [a show];
    }];
}

@end
