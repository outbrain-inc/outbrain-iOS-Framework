//
//  ClassicVCNoImages.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/26/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "ClassicVCNoImages.h"
#import "OBAppDelegate.h"

@implementation ClassicVCNoImages

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"List Without Images";
    
    self.recommendationsView.alpha = 0;
    
    // This is the piece that determines if images show or not.
    self.recommendationsView.showImages = NO;
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
