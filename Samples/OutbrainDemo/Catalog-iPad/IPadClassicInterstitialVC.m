//
//  ClassicInterstitialVC.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "IPadClassicInterstitialVC.h"
#import "OBAppDelegate.h"

@implementation IPadClassicInterstitialVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Interstitial";

    // This is all you have to do for the interstitials
    // Since the requests are controlled within the interstitial themselves
    self.classicInterstitialView.request = [OBRequest requestWithURL:kOBRecommendationLink widgetID:@"SDK_3"];
    self.classicInterstitialView.widgetDelegate = self;
}

- (void)widgetView:(UIView<OBWidgetViewProtocol> *)widgetView tappedRecommendation:(OBRecommendation *)recommendation {
    // This recommendations was tapped.
    // Here is where we register the click with outbrain for this piece of content
    NSURL * url = [Outbrain getOriginalContentURLAndRegisterClickForRecommendation:recommendation];
    
    // Now we have a url that we can show in a webview, or if it's a piece of our native content
    // Then we can inspect [url hash] to get the mobile_id
    
    NSString * message = [NSString stringWithFormat:@"User tapped recommendation.  Need to present content for this url %@", [url absoluteString]];
    
    UIAlertView * a = [[UIAlertView alloc] initWithTitle:@"Recommendation Tapped!" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [a show];
}

- (void)widgetViewTappedBranding:(UIView<OBWidgetViewProtocol> *)widgetView {
    OBAppDelegate * appDelegate = (OBAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showOutbrainAbout];
}

@end
