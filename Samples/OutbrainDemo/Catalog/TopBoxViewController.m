//
//  AdhesionVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "TopBoxViewController.h"
#import "OBAppDelegate.h"

@implementation TopBoxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // This defines how much (in pixels) we want the overview to 'peek' from the bottom.
    self.title = @"Top-Box";
    
    // We handle the fetching ourself
    CGRect textSize = [self.mainTextView textRectForBounds:CGRectMake(10, 0, self.view.frame.size.width - 20, CGFLOAT_MAX) limitedToNumberOfLines:0];
    
    self.mainTextView.frame = textSize;
    self.mainScrollView.contentSize = CGSizeMake(textSize.size.width, textSize.size.height);
    self.mainScrollView.frame = self.view.frame;
    
    self.topBoxView.widgetDelegate = self;
    typeof(self) __weak __self = self;
    
    [Outbrain fetchRecommendationsForRequest:[OBRequest requestWithURL:kOBRecommendationLink widgetID:kOBWidgetID] withCallback:^(OBRecommendationResponse *response) {
        [__self.topBoxView setRecommendationResponse:response];
    }];
}


#pragma mark - ScrollView Delegate

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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat yOff = scrollView.contentOffset.y;
    
    // Check user already scrolled down
    if(!_scrolledDown)
    {
        _scrolledDown = (scrollView.contentOffset.y > 10);
        if(!_scrolledDown) return;
    }
    
    if (_topBoxDocked) {
        return;
    }
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.frame.size.height) {
        return;
    }
    
    CGFloat paralaxRate = 1.5f; // How much should we parallax
    if(!_topBoxLocked)
    {
        // Only start moving the hover view onto the screen if we're scrolling up, and
        // we've scrolled down a little alread
        if(yOff < _previousScrollYOffset && scrollView.contentOffset.y > 10.f)
        {
            // NSLog(@"GO UP");
            // We only scroll the hover view in when scrolling up
            CGRect r = _topBoxView.frame;
            r.origin.y += (_previousScrollYOffset - yOff) * paralaxRate;
            if (r.origin.y >= 0) {
                r.origin.y = 0;
                [self _animateHoverViewToPeekAmount];
            }
            self.topBoxView.frame = r;
        }
        else
        {
            // If we've already scrolled up some then we should scroll down at the same paralax rate vs. locking at the bottom
            if(CGRectGetMaxY(_topBoxView.frame) >= 0 && _previousScrollYOffset < yOff)
            {
                // NSLog(@"GO DOWN");
                CGRect r = _topBoxView.frame;
                r.origin.y += (_previousScrollYOffset - yOff) * paralaxRate;
                
                self.topBoxView.frame = r;
            }
        }
    }
    
    // Reset the previous offset.
    _previousScrollYOffset = scrollView.contentOffset.y;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (_topBoxDocked) return;
    
    if (scrollView.contentOffset.y <= CGRectGetMaxY(_topBoxView.frame) && _topBoxLocked) {
        [self.topBoxView removeFromSuperview];
        
        self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height + self.topBoxView.frame.size.height);

        [UIView animateWithDuration:.25f animations:^{
            self.mainTextView.frame = CGRectMake(self.mainTextView.frame.origin.x, self.topBoxView.frame.size.height, self.mainTextView.frame.size.width, self.mainTextView.frame.size.height);
            [self.mainScrollView addSubview:self.topBoxView];
            self.topBoxView.frame = CGRectMake(0,0,self.topBoxView.frame.size.width, self.topBoxView.frame.size.height);
        }];
        _topBoxDocked = YES;
    }
    // If we're not decelerating, and the outbrain view is currently in view by at least 10 pix.  Then we should animate
    // it in to our 'peek' state
    if(CGRectGetMinY(self.topBoxView.frame) > scrollView.contentOffset.y - 10 && !decelerate) {
        // Here we've gotten stuck.
        [self _animateHoverViewToPeekAmount];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Here in-case our adhesion view is partially in the screen let's go ahead and animate it the rest of the way
    if(_topBoxDocked) return;
    if(_topBoxLocked) return;
    
    CGFloat adhesionYOff = CGRectGetMaxY(self.topBoxView.frame);
    CGFloat scrollYOff = self.mainScrollView.contentOffset.y;
    
    // NSLog(@"did end decelerating");
    if(adhesionYOff > (scrollYOff - self.topBoxView.frame.size.height) && adhesionYOff < scrollYOff)
    {
        // NSLog(@"did end decelerating with animation");
        [self _animateHoverViewToPeekAmount];
    }
    else {
        [UIView animateWithDuration:.25f animations:^{
            self.topBoxView.frame = CGRectMake(0,-_topBoxView.frame.size.height,_topBoxView.frame.size.width, _topBoxView.frame.size.height);
        }];
    }
}

- (void)_animateHoverViewToPeekAmount
{
    if (_topBoxLocked || _topBoxDocked)
        return;
    
    _topBoxLocked = YES;
    mainScrollView.contentSize = CGSizeMake(mainScrollView.contentSize.width, mainScrollView.contentSize.height + _topBoxView.frame.size.height);

    // NSLog(@"animate hover");

    [UIView animateWithDuration:.25f animations:^{
        self.topBoxView.frame = CGRectMake(0,0,_topBoxView.frame.size.width, _topBoxView.frame.size.height);
        self.mainTextView.frame = CGRectOffset(self.mainTextView.frame, 0, _topBoxView.frame.size.height);
    }];
}

@end
