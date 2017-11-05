//
//  PostVC.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "PostViewCell.h"
#import "Post.h"
#import "OBHorizontalWidget.h"
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBDemoDataHelper.h"

/**
 *  Here we'll use the delegate callbacks to confirm those work properly
 **/


@interface PostViewCell () <OBResponseDelegate, UIWebViewDelegate, OBAdhesionViewDelegate, UIGestureRecognizerDelegate>
{
    CGFloat _previousScrollYOffset;
    BOOL _loadingOutbrain;
    BOOL _outbrainLoaded;

    BOOL _adhesionDisabled; // If yes then the adhesion shouldn't be shown or locked into place anymore
    BOOL _adhesionLocked;   // If yes then the adhesion is locked at the bottom of the scroll view
    BOOL _scrolledDown;
}


@end

@implementation PostViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    _outbrainViewHeight = 300.f;
    self.mainScrollView.scrollsToTop = YES;
    self.postContentTextView.textContainerInset = UIEdgeInsetsMake(0, 5.0, 0, 5.0);

}


#pragma mark - Actions

- (void)delayedContentLoad
{
    self.mainScrollView.scrollsToTop = YES;
    // If we've loaded outbrain data already, or we're currently loading then there's nothing else to do.
    if(_outbrainLoaded || _loadingOutbrain) return;
    
    self.mainScrollView.delegate = nil;
    OBRequest * request = [OBRequest requestWithURL:self.post.url widgetID:OBDemoWidgetID3];
    [Outbrain fetchRecommendationsForRequest:request withDelegate:self];
}


#pragma mark - Helpers

- (void)_animateHoverViewToPeekAmount
{
    _adhesionLocked = YES;
    // Here we are partial.  Animate to full
    [UIView animateWithDuration:.25f animations:^{
        self.outbrainHoverView.frame = CGRectOffset(_outbrainHoverView.bounds, 0, CGRectGetMaxY(self.mainScrollView.bounds) - _outbrainHoverView.peekAmount);
    }];
}

#pragma mark - Setters

- (void)setPost:(Post *)post
{
    if ([post isEqual:_post]) {
        return;    // Same post given.  No need to update
    }
    
    _outbrainLoaded = NO;
    _post = post;
    
    
    // Setup the view here
    self.postTitleLabel.text = post.title;
    self.postDateLabel.text = [OBDemoDataHelper _dateStringFromDate:post.date];
    NSAttributedString *bodyString = [OBDemoDataHelper _buildArticleAttributedStringWithPost:post];
    self.postContentTextView.attributedText = bodyString;
    if (post.imageURL) {
        [OBDemoDataHelper fetchImageWithURL:[NSURL URLWithString:post.imageURL] withCallback:^(UIImage *image) {
            self.postImageView.image = image;
        }];
    }
}


#pragma mark - Oubrain Response Delegate

- (void)dismissDebugView:(UIGestureRecognizer *)tp
{
    UIView * control = [tp view];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.25f animations:^{
            control.alpha = 0;
        } completion:^(BOOL finished) {
            [control removeFromSuperview];
        }];
    });
}

- (void)outbrainDidReceiveResponseWithSuccess:(OBRecommendationResponse *)response
{
    _outbrainLoaded = YES;
    _loadingOutbrain = NO;
    _adhesionDisabled = NO;
    _adhesionLocked = NO;
    
    // If there are no recommendations (shouldn't happen often).  Then we
    // just don't show anything
    if (response.recommendations.count == 0)
    {
        [self handleOutbrainErrorOnZeroRecs: response];
        return;
    }

    UIScrollView * sv = self.mainScrollView;
    sv.delegate = self;

    if (response.request.widgetIndex == 0) {
        self.outbrainClassicView.recommendationResponse = response;
        
        // The next 3 lines calculate the new frame height for outbrainClassicView according to the server response
        CGRect newFrame = self.outbrainClassicView.frame;
        newFrame.size = CGSizeMake(newFrame.size.width, [self.outbrainClassicView getHeight]);
        self.outbrainClassicView.frame = newFrame;
        
        // Adjust the TextView contentInset so we can insert outbrainClassicView at the bottom
        UIEdgeInsets insets = sv.contentInset;
        insets.bottom = self.outbrainClassicView.frame.size.height + 10.0; // + offset
        sv.contentInset = insets;

        
        self.outbrainClassicView.frame = CGRectOffset(_outbrainClassicView.bounds, 0, sv.contentSize.height);
        [sv addSubview:self.outbrainClassicView];
        if(sv.contentOffset.y >= CGRectGetMinY(_outbrainClassicView.frame))
        {
            _adhesionDisabled = YES;
        }
        
        self.outbrainClassicView.alpha = 0.f;
        [UIView animateWithDuration:.3f
                         animations:^{
                             self.outbrainClassicView.alpha = 1.f;
                         }];
        

        // Call for the second request, we need to use the token we received from the server
        OBRequest * secondRequest = [OBRequest requestWithURL:self.post.url widgetID:OBDemoWidgetID1 widgetIndex:1];
        [Outbrain fetchRecommendationsForRequest:secondRequest withDelegate:self];
    }
    else {
        self.outbrainHoverView.recommendationResponse = response;
        self.outbrainHoverView.frame = CGRectOffset(_outbrainHoverView.bounds, 0, CGRectGetMaxY(sv.bounds));
        [sv addSubview:self.outbrainHoverView];
        
        self.outbrainHoverView.alpha = 0.f;
    }
}

- (void)outbrainResponseDidFail:(NSError *)response
{
    NSLog(@"Outbrain Error - domain: %@; message: %@", response.domain, response.userInfo[NSLocalizedDescriptionKey]);
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Disabled don't move
    if(_adhesionDisabled) return;
    if(!_scrolledDown)
    {
        _scrolledDown = (scrollView.contentOffset.y > 10);
        if(!_scrolledDown) return;
    }
 
    // Check if we're disabled yet.  If so then we'll go ahead and hide and forget about the other stuff
    _adhesionDisabled = (CGRectGetMaxY(scrollView.bounds) >= CGRectGetMinY(self.outbrainClassicView.frame));
    if(_adhesionDisabled)
    {
        // We have passed our classic recommendations at the bottom.
        [UIView animateWithDuration:.1f animations:^{
            self.outbrainHoverView.alpha = 0.f;
            self.outbrainHoverView.frame = CGRectOffset(self.outbrainHoverView.bounds, 0, CGRectGetMinY(self.outbrainClassicView.frame));
        }];
        return;
    }
    
    CGFloat yOff = CGRectGetMaxY(scrollView.bounds);
    
    CGFloat paralaxRate = 1.5f; // How much should we parallax
    if(!_adhesionLocked)
    {
        // Only start moving the hover view onto the screen if we're scrolling up, and
        // we've scrolled down a little alread
        if(yOff < _previousScrollYOffset && CGRectGetMinY(scrollView.bounds) > 10.f)
        {
            // We only scroll the hover view in when scrolling up
            CGRect r = _outbrainHoverView.frame;
            r.origin.y -= (_previousScrollYOffset - yOff) * paralaxRate;
            self.outbrainHoverView.frame = r;
            self.outbrainHoverView.alpha = 1.f;
            
        }
        else
        {
            // If we've already scrolled up some then we should scroll down at the same paralax rate vs. locking at the bottom
            if(CGRectGetMinY(_outbrainHoverView.frame) + (yOff - _previousScrollYOffset) < yOff)
            {
                yOff = CGRectGetMinY(self.outbrainHoverView.frame);
                yOff += (CGRectGetMaxY(scrollView.bounds) - _previousScrollYOffset) * paralaxRate;
            }
            
            if(scrollView.contentOffset.y < 0 && _previousScrollYOffset < CGRectGetMaxY(scrollView.bounds) && CGRectGetMinY(self.outbrainHoverView.frame) < CGRectGetMaxY(scrollView.bounds)-10)
            {
                // Just go ahead and animate in.  This is the edge case that the user barely scrolled down.  Then scrolled back up
                [self _animateHoverViewToPeekAmount];
            }
            else
                self.outbrainHoverView.frame = CGRectOffset(self.outbrainHoverView.bounds, 0, yOff);
        }
        
        // Check if we're locked.
        _adhesionLocked = CGRectGetMinY(self.outbrainHoverView.frame) <= (CGRectGetMaxY(scrollView.bounds) - self.outbrainHoverView.peekAmount);
    }
    else
    {
        self.outbrainHoverView.alpha = 1;
        // We're locked at the peek amount
        self.outbrainHoverView.frame = CGRectOffset(_outbrainHoverView.bounds, 0, yOff - _outbrainHoverView.peekAmount);
    }
    
    // Reset the previous offset.
    _previousScrollYOffset = CGRectGetMaxY(scrollView.bounds);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(_adhesionLocked || _adhesionDisabled) return;
    
    // If we're not decelerating, and the outbrain view is currently in view by at least 10 pix.  Then we should animate
    // it in to our 'peek' state
    if(CGRectGetMinY(self.outbrainHoverView.frame) < CGRectGetMaxY(scrollView.bounds)-10 && !decelerate) {
        // Here we've gotten stuck.
        [self _animateHoverViewToPeekAmount];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Here in-case our adhesion view is partially in the screen let's go ahead and animate it the rest of the way
    if(_adhesionDisabled) return;
    if(_adhesionLocked) return;
    
    CGFloat adhesionYOff = CGRectGetMinY(self.outbrainHoverView.frame);
    CGFloat scrollYOff = CGRectGetMaxY(self.mainScrollView.bounds);
    
    if(adhesionYOff > (scrollYOff - self.outbrainHoverView.peekAmount) && adhesionYOff < scrollYOff)
    {
        [self _animateHoverViewToPeekAmount];
    }
}


#pragma mark - Adhesion Delegate

- (void)userWillExpandAdhesionView:(OBAdhesionView *)adhesionView
{
    _adhesionDisabled = YES;
}

- (void)userDidCollapseAdhesionView:(OBAdhesionView *)adhesionView
{
    _adhesionDisabled = NO;
}

- (void)userDidDismissAdhesionView:(OBAdhesionView *)adhesionView
{
    _adhesionDisabled = YES;
    [UIView animateWithDuration:.1f animations:^{
        _outbrainHoverView.alpha = 0.f;
        _outbrainHoverView.frame = CGRectOffset(_outbrainHoverView.bounds, 0, CGRectGetMinY(_outbrainHoverView.frame));
    }];
    
}




#pragma mark - Getters

- (OBAdhesionView *)outbrainHoverView
{
    if(!_outbrainHoverView)
    {
        _outbrainHoverView = [[OBAdhesionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.outbrainViewHeight - 105)];
        _outbrainHoverView.delegate = self;
    }
    return _outbrainHoverView;
}

- (OBClassicRecommendationsView *)outbrainClassicView
{
    if(!_outbrainClassicView)
    {
        _outbrainClassicView = [[OBClassicRecommendationsView alloc] initWithFrame:CGRectMake(0, MAXFLOAT, self.bounds.size.width, self.outbrainViewHeight)];
        _outbrainClassicView.backgroundColor = self.backgroundColor;
    }
    
    // Important: we need to set those properties everytime to handle a case of re-use of the cell 
    _outbrainClassicView.widgetId = OBDemoWidgetID1;
    _outbrainClassicView.url = self.post.url;
    
    return _outbrainClassicView;
}


#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.mainScrollView.delegate = nil;
    self.mainScrollView.scrollsToTop = NO;
    self.mainScrollView.contentOffset = CGPointZero;
    
    _previousScrollYOffset = 0;
    
    _scrolledDown =
    _outbrainLoaded =
    _loadingOutbrain =
    _adhesionDisabled =
    _adhesionLocked = NO;
    
    self.outbrainClassicView.widgetDelegate = nil;
    self.outbrainHoverView.widgetDelegate = nil;
    
    [self.outbrainHoverView removeFromSuperview];
    [self.outbrainClassicView removeFromSuperview];
}

-(void) handleOutbrainErrorOnZeroRecs:(OBRecommendationResponse *)response {
    if ([OBDemoDataHelper showsDebugIndicators])
    {
        UITextView * label = [[UITextView alloc] initWithFrame:CGRectInset([[UIScreen mainScreen] bounds], 10.f, 10.f)];
        label.font = [UIFont boldSystemFontOfSize:16.f];
        
        id resObj = [response valueForKey:@"originalOBPayload"];
        NSString * originalRequest = @"";
        if([resObj isKindOfClass:[NSDictionary class]])
        {
            NSData * d = [NSJSONSerialization dataWithJSONObject:resObj options:0 error:nil];
            if(d)
            { originalRequest = [[NSString alloc]  initWithData:d encoding:NSUTF8StringEncoding]; }
        }
        label.editable = NO;
        label.text = [NSString stringWithFormat:@"Recommendation Response for\n'%@'\nreturnned 0 recommendations\n\n%@", self.post.title, originalRequest];
        
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor blackColor];
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDebugView:)];
        [label addGestureRecognizer:tap];
        
        [self.window addSubview:label];
    }
}

@end
