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
    self.textView.scrollsToTop = YES;
    self.textView.textContainerInset = UIEdgeInsetsMake(20.0, 10, 0, 0);
    self.topBoxView = [[OBTopBoxView alloc] initWithFrame:CGRectMake(0, -kTopBoxHeight, self.textView.frame.size.width, kTopBoxHeight)];
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
    
    CGFloat paralaxRate = 1.5f; // How much should we parallax
    if (self.topBoxLocked == NO)
    {
        // Only start moving the hover view onto the screen if we're scrolling up, and
        // we've scrolled down a little alread
        if (yOff < _previousScrollYOffset && scrollView.contentOffset.y > 10.f)
        {
            //NSLog(@"GO UP");
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
            if (CGRectGetMinY(_topBoxView.frame) >= 0 && _previousScrollYOffset < yOff)
            {
                //NSLog(@"GO DOWN");
                CGRect r = _topBoxView.frame;
                r.origin.y += (_previousScrollYOffset - yOff) * paralaxRate;
                
                self.topBoxView.frame = r;
            }
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
    
    //NSLog(@"contentOffset = %@", CGPointCreateDictionaryRepresentation(scrollView.contentOffset));
    //NSLog(@"maxY = %.2f", CGRectGetMinY(_topBoxView.frame));
    //NSLog(@"_topBoxLocked = %@", _topBoxLocked ? @"YES" : @"NO");
    
    if (_topBoxLocked && scrollView.contentOffset.y <= CGRectGetMinY(_topBoxView.frame)) {
        [self dockTopBox];
    }
    
    // If we're not decelerating, and the outbrain view is currently in view by at least 10 pix.  Then we should animate
    // it in to our 'peek' state
//    if(CGRectGetMinY(self.topBoxView.frame) > scrollView.contentOffset.y - 10 && !decelerate) {
//        // Here we've gotten stuck.
//        [self _animateHoverViewToPeekAmount];
//    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Here in-case our adhesion view is partially in the screen let's go ahead and animate it the rest of the way
    if(_topBoxDocked) return;
    if(_topBoxLocked) return;
    
    CGFloat adhesionYOff = CGRectGetMinY(self.topBoxView.frame);
    CGFloat scrollYOff = self.mainScrollView.contentOffset.y;
    
    //NSLog(@"did end decelerating");
    if(adhesionYOff > (scrollYOff - self.topBoxView.frame.size.height) && adhesionYOff < scrollYOff)
    {
        //NSLog(@"did end decelerating with animation");
        [self _animateHoverViewToPeekAmount];
    }
    else {
        [UIView animateWithDuration:.25f animations:^{
            self.topBoxView.frame = CGRectMake(0,-_topBoxView.frame.size.height,_topBoxView.frame.size.width, _topBoxView.frame.size.height);
        }];
    }
    
    if (_topBoxLocked && scrollView.contentOffset.y <= CGRectGetMinY(_topBoxView.frame)) {
        [self dockTopBox];
    }
}

- (void) _animateHoverViewToPeekAmount
{
    if (self.topBoxLocked || self.topBoxDocked) {
        return;
    }
    
    self.topBoxLocked = YES;
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height + self.topBoxView.frame.size.height);
    
    //NSLog(@"animate hover");
    //NSLog(@"FRAME = %@", CGRectCreateDictionaryRepresentation(self.topBoxView.frame));
    
    [UIView animateWithDuration:.25f animations:^{
        self.topBoxView.frame = CGRectMake(0,0,_topBoxView.frame.size.width, self.topBoxView.frame.size.height);
        self.textView.frame = CGRectOffset(self.textView.frame, 0, self.topBoxView.frame.size.height);
    }];
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
    
    self.textView.delegate = nil;
    OBRequest * request = [OBRequest requestWithURL:self.post.url widgetID:OBDemoWidgetID1];
    [Outbrain fetchRecommendationsForRequest:request withDelegate:self];
}

#pragma mark - Setters

- (void)setPost:(Post *)post
{
    if ([post isEqual:_post]) {
        return;    // Same post given.  No need to update
    }

    self.mainScrollView.contentOffset = CGPointZero;
    _outbrainLoaded = NO;
    _topBoxDocked = NO;
    _topBoxLocked = NO;
    
    _post = post;
    
    // Setup the view here
    self.textView.attributedText = [OBDemoDataHelper _buildArticleAttributedStringWithPost:post];
    self.topBoxView.frame = CGRectOffset(self.topBoxView.bounds, 0, -self.topBoxView.frame.size.height);    
    
    [[self.textView viewWithTag:200] removeFromSuperview];
    
    
    if (post.imageURL)
    {
        UIView * imageContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        imageContainerView.backgroundColor = self.backgroundColor;
        imageContainerView.tag = 200;
        [self.textView addSubview:imageContainerView];
        imageContainerView.clipsToBounds = YES;
        
        NSInteger imageRangeStart = NSMaxRange([self.textView.attributedText.string rangeOfString:[OBDemoDataHelper _dateStringFromDate:post.date]]);
        NSInteger imageRangeEnd = NSMaxRange([self.textView.attributedText.string rangeOfString:IMAGE_SPACING]);
        
        __block CGRect rect = self.textView.bounds;
        NSAttributedString * firstAttString = [self.textView.attributedText attributedSubstringFromRange:NSMakeRange(0, imageRangeStart+1)];
        NSAttributedString * secondAttString = [self.textView.attributedText attributedSubstringFromRange:NSMakeRange(0, imageRangeEnd)];
        
        typeof(imageContainerView) __weak __imageContainerView = imageContainerView;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            rect.origin.y = [firstAttString boundingRectWithSize:CGSizeMake(rect.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
            rect.origin.y += 10.f;
            //rect.origin.x = 10.f;
            rect.size.height = [secondAttString boundingRectWithSize:CGSizeMake(rect.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height - rect.origin.y;
            rect.size.height -= 20.f; // Add padding
            //rect.size.width -= 20.f; // Add padding
            
    
            [OBDemoDataHelper fetchImageWithURL:[NSURL URLWithString:post.imageURL] withCallback:^(UIImage *image) {
                // We changed pages before the image got fetched
                if (__imageContainerView.superview == nil) {
                    return;
                }
                __imageContainerView.frame = rect;
                UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectInset(__imageContainerView.bounds, 5, 5)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.backgroundColor = [UIColor greenColor];
                [__imageContainerView addSubview:iv];
                iv.alpha = 0.f;
                iv.image = image;
                [UIView animateWithDuration:.1f animations:^{
                    iv.alpha = 1;
                }];
            }];
        });
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
    self.textView.delegate = (id<UITextViewDelegate>)self; // listen to the scroll events (UITextView is a ScrollView)
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIScrollView *sv = self.mainScrollView;
        UIEdgeInsets insets = sv.contentInset;
        insets.bottom = self.topBoxView.frame.size.height;
        sv.contentInset = insets;
        self.topBoxView.frame = CGRectOffset(self.topBoxView.bounds, 0, -self.topBoxView.frame.size.height);
        
        self.topBoxView.alpha = 0.f;
        [UIView animateWithDuration:.3f
                         animations:^{
                             self.topBoxView.alpha = 1.f;
                         }];
    });
}

- (void)outbrainResponseDidFail:(NSError *)response
{
    NSLog(@"Outbrain Error - domain: %@; message: %@", response.domain, response.userInfo[NSLocalizedDescriptionKey]);
}

- (void)dockTopBox {
    [self.topBoxView removeFromSuperview];
    
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height + self.topBoxView.frame.size.height);
    // NSLog(@"DOCKING TOP BOX");
    [UIView animateWithDuration:.25f animations:^{
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.topBoxView.frame.size.height + 10, self.textView.frame.size.width, self.textView.frame.size.height);
        self.topBoxView.frame = CGRectMake(0,0,self.topBoxView.frame.size.width, self.topBoxView.frame.size.height);
    }];
    [self.mainScrollView addSubview:self.topBoxView];
    
    _topBoxDocked = YES;
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.textView.delegate = nil;
    self.mainScrollView.scrollsToTop = NO;
    self.mainScrollView.contentOffset = CGPointZero;
    
    _previousScrollYOffset = 0;
    
    _loadingOutbrain = NO;
    
    
//    [self.topBoxView removeFromSuperview];
    //    self.outbrainHoverView = nil;
    //    self.outbrainClassicView = nil;
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
