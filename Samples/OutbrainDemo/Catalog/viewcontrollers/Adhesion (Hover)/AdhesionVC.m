//
//  AdhesionVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "AdhesionVC.h"
#import "OBAppDelegate.h"

@implementation AdhesionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This defines how much (in pixels) we want the overview to 'peek' from the bottom.
    self.adhesionView.peekAmount = 90.f;
    self.title = @"Drawer";

    // We handle the fetching ourself
    self.adhesionView.frame = CGRectOffset(self.adhesionView.bounds, 0, CGRectGetMaxY(self.view.bounds));
    self.adhesionView.widgetDelegate = self;

    typeof(self) __weak __self = self;
    
    [Outbrain fetchRecommendationsForRequest:[OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID] withCallback:^(OBRecommendationResponse *response) {
        [__self.adhesionView setRecommendationResponse:response];
        [UIView animateWithDuration:.25f animations:^{
            __self.adhesionView.frame = CGRectOffset(__self.adhesionView.bounds, 0, CGRectGetMaxY(self.view.bounds) - __self.adhesionView.peekAmount);
        }];
    }];
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // If you're trying to reproduce the same effect as what we have put in the Journal app.
    // You will do all of your logic in here.  You can reference `PostViewCell` line 256 and below
}


#pragma mark - AdhesionView Delegate

- (void)userWillExpandAdhesionView:(OBAdhesionView *)adhesionView
{
    // Called when the user pulls up on the arrow to expand the drawer
}

- (void)userDidExpandAdhesionView:(OBAdhesionView *)adhesionView
{
    // Called after the user has expanded the drawer.
}

- (void)userWillCollapseAdhesionView:(OBAdhesionView *)adhesionView
{
    // This is called whenever the drawer is in an expanded state, and the user is about to
    // drag it back down to the condensed state
}

- (void)userDidCollapseAdhesionView:(OBAdhesionView *)adhesionView
{
    // Called after the user finished collapsing the drawer
}

- (void)userDidDismissAdhesionView:(OBAdhesionView *)adhesionView
{
    // Here means the user swiped down on the adhesion view or clicked the x button.
    // You should not show this anymore.
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
