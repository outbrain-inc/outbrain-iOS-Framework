//
//  ClassicVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/18/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "ClassicVC.h"
#import "OBAppDelegate.h"
@import SafariServices;

@implementation ClassicVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"List With Images";

    self.recommendationsView.alpha = 0;
    self.recommendationsView.widgetDelegate = self;
    // Create a request
    OBRequest * request = [OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        // If the response was successful then pass the response to the widget
        
        if(response.error)
        {
            // We want to hide our recommendations view since the request failed to get recommendations
            self.recommendationsView.hidden = YES;
            NSLog(@"Got error from recommendations request %@", response.error);
        }
        else
        {
            // We have a valid list of recommendations.
            self.recommendationsView.recommendationResponse = response;
            [UIView animateWithDuration:.25f animations:^{
                // Fade it in
                self.recommendationsView.alpha = 1;
            }];
        }
        
    }];
}


- (void)widgetView:(UIView<OBWidgetViewProtocol> *)widgetView tappedRecommendation:(OBRecommendation *)recommendation {
    // This recommendations was tapped.
    NSURL * url = [Outbrain getUrl:recommendation];
    
    // Now we have a url that we can show in a webview, or if it's a piece of our native content we can decide what to do with it...
    SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
    [self.navigationController presentViewController:sf animated:YES completion:nil];
}

- (void)widgetViewTappedBranding:(UIView<OBWidgetViewProtocol> *)widgetView {
    OBAppDelegate * appDelegate = (OBAppDelegate *) [[UIApplication sharedApplication] delegate];
    [appDelegate showOutbrainAbout];
}

@end
