//
//  AdhesionVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "ShelfVC.h"
#import "OBAppDelegate.h"

#define NAVIGATION_BAR_PADDING 44.0f
#define STATUS_BAR_PADDING 20.0f
@implementation ShelfVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Shelf";
    // We handle the fetching ourself
    typeof(self) __weak __self = self;
    self.shelfView.widgetDelegate = self;
    
    [Outbrain fetchRecommendationsForRequest:[OBRequest requestWithURL:kOBRecommendationLink widgetID:@"SDK_1"] withCallback:^(OBRecommendationResponse *response) {
        [__self.shelfView setRecommendationResponse:response];
        [UIView animateWithDuration:.25f animations:^{
//__self.shelfView.frame = CGRectOffset(__self.shelfView.bounds, CGRectGetMaxX(self.view.bounds) - __self.shelfView.frame.size.width, NAVIGATION_BAR_PADDING + STATUS_BAR_PADDING);
        }];
    }];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If you're trying to reproduce the same effect as what we have put in the Journal app.
    // You will do all of your logic in here.  You can reference `PostViewCell` line 256 and below
}


#pragma mark - ShelfView Delegate

- (void)userWillExpandShelfView:(OBShelfView *)shelfView {
    // Called when the user pulls up on the arrow to expand the drawer
}

- (void)userDidExpandShelfView:(OBShelfView *)shelfView {
    // Called after the user has expanded the drawer.
}

- (void)userWillCollapseShelfView:(OBShelfView *)shelfView {
    // This is called whenever the drawer is in an expanded state, and the user is about to
    // drag it back down to the condensed state
}

- (void)userDidCollapseShelfView:(OBShelfView *)shelfView {
    // Called after the user finished collapsing the drawer
}

- (void)userDidDismissShelfView:(OBShelfView *)shelfView {
    // Here means the user swiped down on the adhesion view or clicked the x button.
    // You should not show this anymore.
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
