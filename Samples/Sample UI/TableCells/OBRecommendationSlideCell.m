//
//  OBRecommendationSlideCell.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/31/13.
//  Copyright (c) 2013 Mercury Intermedia. All rights reserved.
//

#import "OBRecommendationSlideCell.h"
#import <OutbrainSDK/OutbrainSDK.h>

// View container for a single outbrain slide
@interface OBParalaxSlideViewControl : UIView
@property (nonatomic, strong) UIView * imageContainer;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * sourceLabel;
@end

@interface OBRecommendationSlideCell () <UIScrollViewDelegate>
{
    /**
     *  This is just to make sure that we're only
     *  manipulating our views.  vs doing scrollViewInternal.subviews
     **/
    NSMutableArray * _slideViewsInternal;
}
@property (nonatomic, strong) UIScrollView * scrollViewInternal;

/**
 *  Our current index
 **/
@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, strong) OBLabel * obLabel;

@end


@implementation OBRecommendationSlideCell


#pragma mark - Initialize

- (void)commonInit
{
    self.contentView.backgroundColor = [self _contentBackgroundColor];
    
    // Setup the internal scrollView and what not
    float padding = 5.f;
    CGRect r = CGRectInset(self.contentView.bounds, (padding*2), 10);
    UIScrollView * scrollContainer = [[UIScrollView alloc] initWithFrame:r];
    scrollContainer.delegate = self;
    scrollContainer.backgroundColor = self.contentView.backgroundColor;
    scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    scrollContainer.pagingEnabled = YES;
    scrollContainer.showsHorizontalScrollIndicator = NO;
    scrollContainer.clipsToBounds = NO;
    scrollContainer.multipleTouchEnabled = NO;
    [self.contentView addSubview:scrollContainer];
    self.scrollViewInternal = scrollContainer;
    
    // OBLabel for Viewability
    self.obLabel = [[OBLabel alloc] init]; // registration on OBLabel will be done by PostsListVC in cellForRowAtIndexPath
    self.obLabel.frame = CGRectMake(0, 0, 5, 5);
    self.obLabel.alpha = 0;
    [self.contentView addSubview:self.obLabel];
    
    _slideViewsInternal = [NSMutableArray array];
    
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapGesture.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tapGesture];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{ if((self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Viewability
- (void) setUrl:(NSString *)url andWidgetId:(NSString *)widgetId {
    [Outbrain registerOBLabel:self.obLabel withWidgetId:widgetId andUrl:url];
}


#pragma mark - Touching

- (void)tapAction:(UITapGestureRecognizer *)tapGesture
{
    // The user tapped a recommendation
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[self.currentIndex];
    
    if(self.recommendationTapHandler)
    {
        self.recommendationTapHandler(recommendation);
    }
    
    if(self.widgetDelegate)
    {
        [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
    }
}


#pragma mark - Setters

- (void)setRecommendationResponse:(OBRecommendationResponse *)response
{
//    if([_recommendationResponse isEqual:response]) return;
    _recommendationResponse = response;
    
    // Remove the views that are already there (if any)
    [_scrollViewInternal.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_slideViewsInternal removeAllObjects];
    
    // Here we show 'UP TO' the maxNumberOfRecommendatons.
    // We could have 1,2,3
    NSInteger numberOfRecommendations = [response recommendations].count;
    
    // Setup the scroll container so we can swipe
    _scrollViewInternal.delegate = nil;
    self.scrollViewInternal.contentSize = CGSizeMake(numberOfRecommendations * _scrollViewInternal.bounds.size.width, 0);
    _scrollViewInternal.contentOffset = CGPointZero;
    
    // Our bounds for each slide
    CGRect rect = CGRectInset(_scrollViewInternal.bounds, 0, 0);
    for(int i = 0; i < numberOfRecommendations; i++)
    {
        @autoreleasepool {
            CGRect r = CGRectOffset(rect, i*(rect.size.width), 0);
            OBParalaxSlideViewControl * recommendationSlide = [self _newSlideViewWithFrame:r withRecommendation:response.recommendations[i]];
            recommendationSlide.imageContainer.backgroundColor = self.contentView.backgroundColor;
            recommendationSlide.imageContainer.layer.shadowColor = [self.contentView.backgroundColor CGColor];
            [_scrollViewInternal addSubview:recommendationSlide];
            [_slideViewsInternal addObject:recommendationSlide];
        }
    }
    self.currentIndex = 0;
    _scrollViewInternal.delegate = self;
}


#pragma mark - Helpers

- (UIColor *)_contentBackgroundColor
{
    return [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.000];
}

/**
 *  Create a new slideView and setup it's positioning with the given recommendation
 **/
- (OBParalaxSlideViewControl *)_newSlideViewWithFrame:(CGRect)frame withRecommendation:(OBRecommendation *)recommendation
{
    OBParalaxSlideViewControl * slideControl = [[OBParalaxSlideViewControl alloc] initWithFrame:frame];
    slideControl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    slideControl.titleLabel.text = recommendation.content;
    slideControl.sourceLabel.text = [NSString stringWithFormat:@"(%@)", (recommendation.source ? recommendation.source : recommendation.author)];
    
    // First check if there's an image
    slideControl.imageContainer.hidden = (recommendation.image == nil);
    
    typeof(slideControl) __weak __slideControl = slideControl;
    [self fetchImageForURL:recommendation.image.url withCallback:^(UIImage *image) {
        __slideControl.imageView.image = image;
        if ([recommendation isRTB]) {
            [Outbrain prepare:__slideControl.imageView withRTB:recommendation onClickBlock:^(NSURL *url) {
                NSLog(@"OBParalaxSlideViewControl --> click url: %@", url.absoluteString);
                [[UIApplication sharedApplication] openURL: url];
            }];
        }
    }];
    
    return slideControl;
}

- (void)_updateFrameForSlide:(OBParalaxSlideViewControl *)slideControl withRecommendation:(OBRecommendation *)recommendation
{
    CGFloat padding = 5.f;
    
    slideControl.imageContainer.transform = CGAffineTransformIdentity;
    CGRect rect = slideControl.titleLabel.frame;
    rect.origin.x = (recommendation.image != nil) ? CGRectGetMaxX(slideControl.imageContainer.frame) + padding : padding;
    rect.size.width = slideControl.bounds.size.width - rect.origin.x - padding;
    rect.origin.y = 2.f;
    rect.size.height = slideControl.bounds.size.height - rect.origin.y - padding;
    
    // Autosize the titleLabel
    slideControl.titleLabel.frame = rect;
    [slideControl.titleLabel sizeToFit];
    rect.size.height = slideControl.titleLabel.frame.size.height;
    slideControl.titleLabel.frame = rect;
    
    // Size the sourceLabel
    rect.origin.y = CGRectGetMaxY(slideControl.titleLabel.frame);
    rect.size.height = slideControl.bounds.size.height - rect.origin.y - padding;
    slideControl.sourceLabel.frame = rect;
    [slideControl.sourceLabel sizeToFit];

}

- (void)fetchImageForURL:(NSURL *)url withCallback:(void (^)(UIImage *))callback
{
    
    BOOL (^ReturnHandler)(UIImage *) = ^(UIImage *returnImage) {
        if(!returnImage) return NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(returnImage);
        });
        return YES;
    };
    
    __block UIImage * responseImage = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * key = @([url.absoluteString hash]).stringValue;
        // Next check if the image is on disk.  If it is then we'll go ahead and add it to the cache and return from the cache
        NSString * cachesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.ob.images"];
        NSFileManager * fm = [[NSFileManager alloc] init];
        [fm createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * diskCachePath = [cachesDir stringByAppendingPathComponent:key];
        
        // We have this on disk.
        responseImage = [UIImage imageWithContentsOfFile:diskCachePath];
        if(!ReturnHandler(responseImage))
        {
            // Fetch the image
            NSData * d = [NSData dataWithContentsOfURL:url];
            if(d)
            {
                responseImage = [UIImage imageWithData:d];
                ReturnHandler(responseImage);
                [d writeToFile:diskCachePath atomically:YES];
            }
        }
        
    });
}

// Reset the image back to it's original position
- (void)resetViewAtIndexToOriginalPosition:(NSInteger)index
{
    if(index >= _slideViewsInternal.count) return;
    OBParalaxSlideViewControl * sv = _slideViewsInternal[index];
    
    sv.transform = CGAffineTransformIdentity;
    if(index == self.currentIndex || index > self.currentIndex)
    {
        sv.imageContainer.transform = CGAffineTransformIdentity;
    }
    else if(index < self.currentIndex)
    {
        sv.imageContainer.transform = CGAffineTransformMakeTranslation(sv.bounds.size.width - sv.imageContainer.frame.size.width - 5.f, 0);
    }
}

/**
 *  This is the meat of the percentage scrolling. 
 *  When scrollOffset changes we call this to recalculate the imageView transforms
 **/
- (void)_updateScrollViewSlides
{
    UIScrollView * scrollView = _scrollViewInternal;
    
    CGFloat offset = scrollView.contentOffset.x;
    
    CGFloat wtf = fmod(offset, scrollView.frame.size.width);
    CGFloat allowableInterval = CGRectGetHeight(scrollView.frame);
    scrollView.clipsToBounds = (wtf >= allowableInterval && wtf <= (scrollView.frame.size.width - allowableInterval));
    
    // We only need to worry about the views upto the _currentIndex
    for(NSInteger index = 0; index <= _currentIndex; index++)
    {
        // Get the slide for the given index
        OBParalaxSlideViewControl * currentSlideView = _slideViewsInternal[index];
        
        CGFloat slideOffset = CGRectGetMinX(currentSlideView.frame);    // Current slideViews origin.x
        
        CGFloat moveBy = (offset - slideOffset); // How much to moveBy
        CGFloat maxMove = CGRectGetWidth(currentSlideView.frame) - currentSlideView.imageView.bounds.size.width - 10.f;
        
        moveBy = MAX(moveBy, 0);        // Don't use negative offsets since we're using the `MakeTranslation` vs. `Translate`
        moveBy = MIN(moveBy,maxMove);   // Cap move by the max x of the current slide
        
        
        // Here we transform the imageContainer.  This gives us the 'pushing' type of animation
        currentSlideView.imageContainer.transform = CGAffineTransformMakeTranslation(moveBy, 0);
    }
}


#pragma mark - Scroll View Delegate

/**
 *  Here we're going to do some fancy image offset stuff.  This allows us to see images
 *  on both sides (when there is a recommendation on the left and on the right), 
 *  and has a nice little paralax type effect when scrolling
 **/
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView != _scrollViewInternal) return;
    
    [self _updateScrollViewSlides];
}

/**
 *  When we're done scrolling let's animate the images to the final place so we don't have any jumping issues
 **/
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView != _scrollViewInternal) return;
    
    NSInteger index = ceil(scrollView.contentOffset.x / scrollView.frame.size.width);
    index = MIN(index, [_slideViewsInternal count]-1);  // Index can't be greater than the number of slides we have
    self.currentIndex = index;
    
    // Here we do any cleanup.  In the case that our `scrollViewDidScroll:` either went to fast, or didn't get called
    // at all.  We'll go ahead and animate the necessary images to their proper place
    [UIView animateWithDuration:.2f animations:^{
        for(int i = 0; i < [_slideViewsInternal count]; i++)
        {
            [self resetViewAtIndexToOriginalPosition:i];
        }
    }];
}


#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollViewInternal.contentSize = CGSizeMake(_scrollViewInternal.frame.size.width*_slideViewsInternal.count, 0);
    self.scrollViewInternal.contentOffset = CGPointMake(self.currentIndex * _scrollViewInternal.frame.size.width, 0);
    
    CGRect rect = CGRectInset(_scrollViewInternal.frame, 0, 0);
    rect.origin = CGPointZero;
    for(OBParalaxSlideViewControl * slide in _slideViewsInternal)
    {
        NSInteger index = [_slideViewsInternal indexOfObject:slide];
        slide.frame = CGRectOffset(rect, index*rect.size.width, 0);
    
        [self _updateFrameForSlide:slide withRecommendation:self.recommendationResponse.recommendations[index]];
    }
}

@end



/**
 *  Our slide container view implementation
 **/

@implementation OBParalaxSlideViewControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.clipsToBounds = YES;
        
        float padding = 5.f;
        // The imageContainer will mask the text for us on the left of the image when scrolling.
        // On the right it will have a shadow
        UIView * imageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.height)];
        imageContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        imageContainer.layer.shadowOffset = CGSizeMake(2, 0);
        imageContainer.layer.shadowOpacity = 1.f;
        imageContainer.layer.shadowRadius = padding;
        imageContainer.layer.shadowColor = [UIColor whiteColor].CGColor;
        [self addSubview:imageContainer];
        self.imageContainer = imageContainer;
        
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(padding, padding, imageContainer.frame.size.width-padding, imageContainer.frame.size.height - (padding*2))];
        imageView.layer.borderWidth = 1.f;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        imageView.backgroundColor = [UIColor lightGrayColor];
        [_imageContainer addSubview:imageView];
        self.imageView = imageView;
        
        CGRect rect = CGRectMake(CGRectGetMaxX(imageContainer.frame), CGRectGetMinY(imageView.frame), MAXFLOAT, 30);
        rect.size.width = (frame.size.width - rect.origin.x);
        
        UILabel * titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.numberOfLines = 2.f;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        rect.origin.y = CGRectGetMaxY(titleLabel.frame);
        UILabel * sourceLabel = [[UILabel alloc] initWithFrame:rect];
        sourceLabel.textColor = [UIColor lightGrayColor];
        sourceLabel.numberOfLines = 1;
        sourceLabel.backgroundColor = [UIColor clearColor];
        sourceLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:sourceLabel];
        self.sourceLabel = sourceLabel;
        
        [self bringSubviewToFront:self.imageContainer];
    }
    return self;
}


@end
