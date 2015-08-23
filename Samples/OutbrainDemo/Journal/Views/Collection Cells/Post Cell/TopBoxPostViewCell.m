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

@interface TopBoxPostViewCell () <OBResponseDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate>
{
    BOOL    _topBoxLocked;
    BOOL    _topBoxDocked;
    
    float   _previousScrollYOffset;

    BOOL _loadingOutbrain;
    BOOL _outbrainLoaded;

    BOOL _scrolledDown;
}

@end

@implementation TopBoxPostViewCell
@synthesize textView;
@synthesize mainScrollView;

#pragma mark - ScrollView Delegate

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
            NSLog(@"GO UP");
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
            if(CGRectGetMinY(_topBoxView.frame) >= 0 && _previousScrollYOffset < yOff)
            {
                NSLog(@"GO DOWN");
                CGRect r = _topBoxView.frame;
                r.origin.y += (_previousScrollYOffset - yOff) * paralaxRate;
                
                self.topBoxView.frame = r;
            }
        }
    }
    
    // Reset the previous offset.
    _previousScrollYOffset = scrollView.contentOffset.y;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (_topBoxDocked) return;

    if (_topBoxLocked && targetContentOffset->y <= CGRectGetMinY(_topBoxView.frame)) {
        [self dockTopBox];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"Scroll view did end dragging");
    if (_topBoxDocked) return;
    
    NSLog(@"contentOffset = %@", CGPointCreateDictionaryRepresentation(scrollView.contentOffset));
    NSLog(@"maxY = %.2f", CGRectGetMinY(_topBoxView.frame));
    NSLog(@"_topBoxLocked = %@", _topBoxLocked ? @"YES" : @"NO");
    
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
    
    NSLog(@"did end decelerating");
    if(adhesionYOff > (scrollYOff - self.topBoxView.frame.size.height) && adhesionYOff < scrollYOff)
    {
        NSLog(@"did end decelerating with animation");
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

- (void)_animateHoverViewToPeekAmount
{
    if (_topBoxLocked || _topBoxDocked)
        return;
    
    _topBoxLocked = YES;
    mainScrollView.contentSize = CGSizeMake(mainScrollView.contentSize.width, mainScrollView.contentSize.height + _topBoxView.frame.size.height);
    
    NSLog(@"animate hover");
    NSLog(@"FRAME = %@", CGRectCreateDictionaryRepresentation(self.topBoxView.frame));
    
    [UIView animateWithDuration:.25f animations:^{
        self.topBoxView.frame = CGRectMake(0,0,_topBoxView.frame.size.width, _topBoxView.frame.size.height);
        self.textView.frame = CGRectOffset(self.textView.frame, 0, _topBoxView.frame.size.height);
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
    
    self.mainScrollView.delegate = nil;
    OBRequest * request = [OBRequest requestWithURL:self.post.url widgetID:OBDemoWidgetID2];
    [Outbrain fetchRecommendationsForRequest:request withDelegate:self];
}


#pragma mark - Helpers

- (NSString *)_dateStringFromDate:(NSDate *)date
{
    // Next the date
    static NSDateFormatter * formatter = nil;
    if(!formatter)
    {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"EEEE, MMMM d, yyyy hh:mm a z"];
    }
    return [formatter stringFromDate:date];
}


#define IMAGE_SPACING @"\n\n\n\n\n"

- (NSAttributedString *)_buildArticleAttributedStringWithPost:(Post *)post
{
    NSString * postTitle = post.title;
    NSString * dateString = [self _dateStringFromDate:post.date];
    NSString * bodyString = [post.body stringByStrippingHTML];
    bodyString = [bodyString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString * articleString = [NSString stringWithFormat:@"%@\n%@\n%@%@", postTitle, dateString, post.imageURL?IMAGE_SPACING:@"", bodyString];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 10.f;
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.paragraphSpacing = 15.f;
    paragraphStyle.paragraphSpacingBefore = 10.f;
    
    UIColor * lightGrayTextColor = [UIColor colorWithRed:0.475 green:0.475 blue:0.475 alpha:1.000];
    NSMutableAttributedString * articleAttributedString = [[NSMutableAttributedString alloc] initWithString:articleString attributes:@{NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:lightGrayTextColor}];
    
    [articleAttributedString addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor blackColor]} range:[articleString rangeOfString:postTitle]];
    [articleAttributedString addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} range:[articleString rangeOfString:bodyString]];
    return articleAttributedString;
}

#pragma mark - Setters

- (void)setPost:(Post *)post
{
    if([post isEqual:_post]) {
        return;    // Same post given.  No need to update
    }

    self.mainScrollView.contentOffset = CGPointZero;
    _outbrainLoaded = NO;
    _topBoxDocked = NO;
    _topBoxLocked = NO;
    
    _post = post;
    
    // Setup the view here
    self.mainScrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.mainScrollView.contentInset = UIEdgeInsetsZero;
    self.textView.attributedText = [self _buildArticleAttributedStringWithPost:post];
    self.topBoxView.frame = CGRectOffset(self.topBoxView.bounds, 0, -self.topBoxView.frame.size.height);

    // We handle the fetching ourself
    CGRect textSize = [self.textView textRectForBounds:CGRectMake(10, 0, self.frame.size.width - 20, CGFLOAT_MAX) limitedToNumberOfLines:0];
    
    self.textView.frame = textSize;
    self.mainScrollView.contentSize = CGSizeMake(textSize.size.width, textSize.size.height);
    
    [[self.textView viewWithTag:200] removeFromSuperview];
    
    
    if(post.imageURL)
    {
        UIView * imageContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        imageContainerView.backgroundColor = self.backgroundColor;
        imageContainerView.tag = 200;
        [self.textView addSubview:imageContainerView];
        imageContainerView.clipsToBounds = YES;
        
        NSInteger imageRangeStart = NSMaxRange([self.textView.attributedText.string rangeOfString:[self _dateStringFromDate:post.date]]);
        NSInteger imageRangeEnd = NSMaxRange([self.textView.attributedText.string rangeOfString:IMAGE_SPACING]);
        
        __block CGRect rect = self.textView.bounds;
        NSAttributedString * firstAttString = [self.textView.attributedText attributedSubstringFromRange:NSMakeRange(0, imageRangeStart+1)];
        NSAttributedString * secondAttString = [self.textView.attributedText attributedSubstringFromRange:NSMakeRange(0, imageRangeEnd)];
        
        typeof(imageContainerView) __weak __imageContainerView = imageContainerView;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            rect.origin.y = [firstAttString boundingRectWithSize:CGSizeMake(rect.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
            rect.size.height = [secondAttString boundingRectWithSize:CGSizeMake(rect.size.width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height - rect.origin.y;
            rect.size.height -= 20.f; // Add padding at the bottom of the image
            if(!__imageContainerView.superview) return;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                __imageContainerView.frame = rect;
            });
            
            
            [OBDemoDataHelper fetchImageWithURL:[NSURL URLWithString:post.imageURL] withCallback:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // We changed pages before the image got fetched
                    if(!__imageContainerView.superview) return;
                    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectInset(__imageContainerView.bounds, 5, 0)];
                    iv.contentMode = UIViewContentModeScaleAspectFill;
                    iv.backgroundColor = [UIColor greenColor];
                    [__imageContainerView addSubview:iv];
                    iv.alpha = 0.f;
                    iv.image = image;
                    [UIView animateWithDuration:.1f animations:^{
                        iv.alpha = 1;
                    }];
                });
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
    _outbrainLoaded = YES;
    _loadingOutbrain = NO;

    // If there are no recommendations (shouldn't happen often).  Then we
    // just don't show anything
    if(response.recommendations.count == 0)
    {
        if([OBDemoDataHelper showsDebugIndicators])
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
        return;
    }
    
    
    
    
    self.topBoxView.recommendationResponse = response;
    
    // Adjust the webView contentInset so we can insert our view at the bottom
    UIScrollView * sv = self.mainScrollView; // self.webView.scrollView; <!-- Maybe use this later
    sv.delegate = self;
    
    UIEdgeInsets insets = sv.contentInset;
    insets.bottom = self.topBoxView.frame.size.height;
    sv.contentInset = insets;
    self.topBoxView.frame = CGRectOffset(self.topBoxView.bounds, 0, -self.topBoxView.frame.size.height);
    
    self.topBoxView.alpha = 0.f;
    [UIView animateWithDuration:.3f
                     animations:^{
                         self.topBoxView.alpha = 1.f;
                     }];
}

- (void)outbrainResponseDidFail:(NSError *)response
{
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:response.domain message:response.userInfo[NSLocalizedDescriptionKey] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (void)dockTopBox {
    [self.topBoxView removeFromSuperview];
    
    self.mainScrollView.contentSize = CGSizeMake(self.mainScrollView.contentSize.width, self.mainScrollView.contentSize.height + self.topBoxView.frame.size.height);
    NSLog(@"DOCKING TOP BOX");
    [UIView animateWithDuration:.25f animations:^{
        self.textView.frame = CGRectMake(self.textView.frame.origin.x, self.topBoxView.frame.size.height, self.textView.frame.size.width, self.textView.frame.size.height);
        self.topBoxView.frame = CGRectMake(0,0,self.topBoxView.frame.size.width, self.topBoxView.frame.size.height);
    }];
    [self.mainScrollView addSubview:self.topBoxView];
    
    _topBoxDocked = YES;
}

#pragma mark - Reuse

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.mainScrollView.delegate = nil;
    self.mainScrollView.scrollsToTop = NO;
//    self.mainScrollView.contentOffset = CGPointZero;
    
    _previousScrollYOffset = 0;
    
    _loadingOutbrain = NO;
    
    
//    [self.topBoxView removeFromSuperview];
    //    self.outbrainHoverView = nil;
    //    self.outbrainClassicView = nil;
}

@end
