//
//  TopBoxPostViewCell.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 3/1/15.
//  Copyright (c) 2015 Mercury Intermedia. All rights reserved.
//

#import "TopBoxPostViewCell.h"
#import "Post.h"
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBDemoDataHelper.h"

@interface TopBoxPostViewCell () <OBResponseDelegate, UIGestureRecognizerDelegate>


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTopPaddingHeightConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBoxVerticalConstraint;


@property (assign, nonatomic) BOOL topBoxLocked;
@property (assign, nonatomic) BOOL topBoxDocked;

@property (assign, nonatomic) BOOL loadingOutbrain;
@property (assign, nonatomic) BOOL outbrainLoaded;

@property (assign, nonatomic) BOOL scrolledDown;
@property (assign, nonatomic) float previousScrollYOffset;

@end

@implementation TopBoxPostViewCell

const CGFloat kTopBoxHeight = 100.0;

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.mainScrollView.scrollsToTop = YES;
    self.postContentTextView.textContainerInset = UIEdgeInsetsMake(0, 5.0, 0, 5.0);

}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat yOff = scrollView.contentOffset.y;
    
    // Check user already scrolled down
    if (self.scrolledDown == NO)
    {
        self.scrolledDown = (scrollView.contentOffset.y > 10);
        if (!self.scrolledDown) return;
    }
    
    if (self.topBoxDocked) {
        return;
    }
    
    // if we are scrolling to the bottom of the screen, don't do anything (we have the bottom widget already)
    if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
        return;
    }
    
    if (self.topBoxLocked == NO)
    {
        // Only start moving the hover view onto the screen if we're scrolling up, and
        // we've scrolled down a little alread
        if (yOff < _previousScrollYOffset && scrollView.contentOffset.y > 10.f)
        {
            //NSLog(@"GO UP");
            // We only scroll the hover view in when scrolling up
            [self dockTopBox];
        }
    }
    
    // Reset the previous offset.
    self.previousScrollYOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_topBoxDocked) return;

    if (_topBoxLocked && targetContentOffset->y <= CGRectGetMinY(_topBoxView.frame)) {
        [self dockTopBox];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"Scroll view did end dragging");
    if (_topBoxDocked) return;
    
    if (_topBoxLocked && scrollView.contentOffset.y <= CGRectGetMinY(_topBoxView.frame)) {
        [self dockTopBox];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Here in-case our adhesion view is partially in the screen let's go ahead and animate it the rest of the way
    if(_topBoxDocked) return;
    if(_topBoxLocked) return;
    
    if (_topBoxLocked && scrollView.contentOffset.y <= CGRectGetMinY(_topBoxView.frame)) {
        [self dockTopBox];
    }
}


////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

#pragma mark - Actions

- (void)delayedContentLoad
{
    self.mainScrollView.scrollsToTop = YES;
    // If we've loaded outbrain data already, or we're currently loading then there's nothing else to do.
    if(_outbrainLoaded || _loadingOutbrain) return;
    
    self.mainScrollView.delegate = nil;
    OBRequest * request = [OBRequest requestWithURL:self.post.url widgetID:OBDemoWidgetID1];
    [Outbrain fetchRecommendationsForRequest:request withDelegate:self];
}

#pragma mark - Setters

- (void)setPost:(Post *)post
{
    if ([post isEqual:_post]) {
        return;    // Same post given.  No need to update
    }

    _outbrainLoaded = NO;
    _topBoxDocked = NO;
    _topBoxLocked = NO;
    
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
    self.outbrainLoaded = YES;
    self.loadingOutbrain = NO;

    // If there are no recommendations (shouldn't happen often). Then we just don't show anything
    if (response.recommendations.count == 0)
    {
        [self handleOutbrainErrorOnZeroRecs: response];
        return;
    }
    
    self.topBoxView.recommendationResponse = response;    
    self.mainScrollView.delegate = (id<UITextViewDelegate>)self; // listen to the scroll events
}

- (void)outbrainResponseDidFail:(NSError *)response
{
    NSLog(@"Outbrain Error - domain: %@; message: %@", response.domain, response.userInfo[NSLocalizedDescriptionKey]);
}

- (void)dockTopBox {
    [self.contentView bringSubviewToFront:self.topBoxView];
    self.topBoxView.hidden = NO;
    self.topBoxVerticalConstraint.constant = -100.0;
    self.titleTopPaddingHeightConstraint.constant = 100.0;
    [UIView animateWithDuration:0.5 animations:^{
        [self.contentView layoutIfNeeded];
        //self.topBoxView.hidden = NO;
        //self.topPaddingView.hidden = YES;
    }];
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.mainScrollView.delegate = nil;
    self.mainScrollView.scrollsToTop = NO;
    self.topBoxView.hidden = YES;
    self.titleTopPaddingHeightConstraint.constant = 5.0;
    self.topBoxVerticalConstraint.constant = 0;
    _loadingOutbrain = NO;
    self.topBoxDocked = NO;
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
