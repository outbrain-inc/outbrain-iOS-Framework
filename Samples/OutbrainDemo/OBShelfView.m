//
//  OBHoverView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBShelfView.h"
#import <OutbrainSDK/OBRecommendationResponse.h>
#import "OBDemoDataHelper.h"
#import "OBLabelExtensions.h"

#define ARROW_HEIGHT 9.f
#define PEEK_LEVEL 35.0f
#define CELL_SIZE 250.0f
#define CELL_PADDING 30.0f
#define IMAGE_VIEW_HEIGHT 80.0f
#define IMAGE_VIEW_PADDING 10.0f
#define STATUS_BAR_AND_NAVIGATION_BAR_TOP_PADDING 64.0f

@interface OBShelfHeader : UIView
@property (nonatomic, strong) UIView *orangeContainer;
@property (nonatomic, assign) float ameliaHeaderHeight;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *brandingImageButton;
/**
 *  Mimic the control center arrow
 **/
@property (nonatomic, strong) CAShapeLayer * arrowLayer;
/**
 *  Discussion:
 *      The current arrow state
 *
 *  Default: OBArrowStateUp
 **/
@property (nonatomic, assign) OBHoverArrowState arrowState;

@property (nonatomic, assign) id<OBShelfHeaderDelegate> delegate;

@end


@interface OBShelfView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
{
    BOOL _appliedPadding;
    UIView * _oldSuperView;
}
@property (nonatomic, strong) UIView * shadowOverlayView;

/**
 *  Internal scroll container
 **/
@property (nonatomic, strong) UICollectionView * internalCollectionView;
@property (nonatomic, strong) UIView *collectionViewBackground;
@property (nonatomic, strong) OBShelfHeader *shelfHeader;

@end

@implementation OBShelfView

#pragma mark - Initialize

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapRecognizer.numberOfTapsRequired = 1.f;
    tapRecognizer.numberOfTouchesRequired = 1.f;
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    
    
    // Setup our collection view
    CGRect contentRect = [self hoverBounds];
    contentRect.size.width += 100;
    contentRect.origin.x += 15; // fake header

    self.collectionViewBackground = [[UIView alloc] initWithFrame:contentRect];
    self.collectionViewBackground.backgroundColor = [UIColorFromRGB(0xF4F4F4) colorWithAlphaComponent:0.94f];
    [self addSubview:self.collectionViewBackground];
    
    
    self.shelfHeader = [[OBShelfHeader alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width + 15 - CELL_PADDING, 40)];
    self.shelfHeader.backgroundColor = [UIColor clearColor];
    self.shelfHeader.ameliaHeaderHeight = 5.0f;
    self.shelfHeader.arrowState = OBHoverArrowStateLeft;
    self.shelfHeader.delegate = self;
    
    UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
    layout.itemSize = CGSizeMake(100, 100);
    layout.sectionInset = UIEdgeInsetsMake(10.0f, CELL_PADDING, 100.0f, CELL_PADDING);

    contentRect.size.width -= 100;
    contentRect.origin.y = CGRectGetMaxY(self.shelfHeader.frame) - 13; //fake triangle
    contentRect.size.height -= CGRectGetMaxY(self.shelfHeader.frame) - 13;
    UICollectionView * cv = [[UICollectionView alloc] initWithFrame:contentRect collectionViewLayout:layout];
    cv.backgroundColor = [UIColor clearColor];
    cv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    cv.delegate = self;
    cv.dataSource = self;
    cv.scrollEnabled = NO;
    [self addSubview:cv];

    [self addSubview:self.shelfHeader];

    [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    _internalCollectionView = cv;
    
    
    // Add our gesture recognizers for doing our extra custom stuff
    UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    
    // We want our pan gesture to be first class
    NSArray * recognizers = [self.internalCollectionView gestureRecognizers];
    
    // Make the default gesture recognizer wait until the custom one fails.
    for (UIGestureRecognizer* aRecognizer in recognizers)
    {
        if ([aRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        {
            [aRecognizer requireGestureRecognizerToFail:pan];
        }
    }
    [self addGestureRecognizer:pan];
    
    typeof(self) __weak __self = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillChangeStatusBarOrientationNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        [__self.internalCollectionView.collectionViewLayout invalidateLayout];
    }];
    
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Actions

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        return NO;
    }
    
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        return YES;

    return (otherGestureRecognizer.view == self.internalCollectionView);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        if(CGRectContainsPoint(CGRectMake(0,0,PEEK_LEVEL, self.frame.size.height), [touch locationInView:self.internalCollectionView]))
        {
            self.internalCollectionView.scrollEnabled = NO;
            return YES;
        }
        
        return self.shelfHeader.arrowState == OBHoverArrowStateLeft;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        // Check if our tap gesture is within our arrowLayer.
        if(CGRectContainsPoint(self.shelfHeader.arrowLayer.frame, [gestureRecognizer locationInView:self]))
        {
            return YES;
        }
    }
    else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return YES;
    }
    if (self.shelfHeader.arrowState == OBHoverArrowStateRight) {
        if(!CGRectContainsPoint(self.frame, [gestureRecognizer locationInView:self.window.rootViewController.view]))
            return YES;
    }
    return NO;
}

- (void)tapAction:(UITapGestureRecognizer *)tapper
{
    if(self.shelfHeader.arrowState == OBHoverArrowStateRight)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(userWillCollapseShelfView:)])
        {
            [self.delegate userWillCollapseShelfView:self];
        }
        // Animate right
        self.shelfHeader.arrowState = OBHoverArrowStateLeft;
        CALayer * l = [_shadowOverlayView.layer.sublayers firstObject];
        CABasicAnimation * a = [CABasicAnimation animationWithKeyPath:@"opacity"];
        a.fromValue = @(l.opacity);
        a.toValue = @0.f;
        a.duration = .3f;
        [l addAnimation:a forKey:nil];
        l.opacity = .0f;
        
        [UIView animateWithDuration:.25f animations:^{
            self.frame = CGRectOffset(self.bounds, CGRectGetMaxX(self.superview.bounds) - PEEK_LEVEL , STATUS_BAR_AND_NAVIGATION_BAR_TOP_PADDING);
        } completion:^(BOOL finished) {
            [self _setupForCollapsed:NO];
        }];
    }
    else if(self.shelfHeader.arrowState == OBHoverArrowStateLeft)
    {
        // Animate Up
        self.shelfHeader.arrowState = OBHoverArrowStateRight;
        [self _setupForExpand];
        
        CALayer * l = [_shadowOverlayView.layer.sublayers firstObject];
        CABasicAnimation * a = [CABasicAnimation animationWithKeyPath:@"opacity"];
        a.fromValue = @0.f;
        a.toValue = @(.6f);
        a.duration = .3f;
        [l addAnimation:a forKey:nil];
        l.opacity = .6f;
        
        [UIView animateWithDuration:.3f
                         animations:^{
                             self.frame = CGRectOffset(self.bounds, CGRectGetMaxX(self.shadowOverlayView.bounds) - [self hoverBounds].size.width, STATUS_BAR_AND_NAVIGATION_BAR_TOP_PADDING);
                         } completion:^(BOOL finished) {
                             if(self.delegate && [self.delegate respondsToSelector:@selector(userDidExpandShelfView:)])
                             {
                                 [self.delegate userDidExpandShelfView:self];
                             }
                             
                         }];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)pan
{
    static CGPoint startPoint;
    
    if(pan.state == UIGestureRecognizerStateBegan)
    {
        [self _setupForExpand];
    }
    
    // The current point that we're dragging at
    CGPoint translatedPoint = [pan translationInView:self.superview];
    
    // Rect of the hoverview
    CGRect rect = self.frame;
    
    // Here our viewBounds is a little smaller than our actual
    // hoverview size.  This is done so we can have a pull up effect like in control
    // center.
    rect.size = [self hoverBounds].size;
    
    // Now we update the arrow based on current position
    CGFloat minOff = (CGRectGetMaxX(self.superview.bounds) - [self hoverBounds].size.width + [self bounds].size.width/2.f);
    CGFloat maxOff = (self.superview.bounds.size.width - PEEK_LEVEL + self.bounds.size.width / 2);
    
    CGFloat diff = (maxOff - minOff);
    
    // Here we want the user to be able to slide up/down our outbrain hover view
    if(pan.state == UIGestureRecognizerStateBegan)
    {
        // Reset the start point everytime we begin touching
        startPoint = self.center;
    }
    
    // Adjust the translatedPoint based on our start offset.
    // We are only changing the y value here
    translatedPoint = CGPointMake(startPoint.x + translatedPoint.x, startPoint.y);
    
    CGFloat initialXOff = translatedPoint.x;
    translatedPoint.x = MAX(translatedPoint.x, minOff);
    
    if(pan.state == UIGestureRecognizerStateChanged)
    {
        
        // This gives us the pulling effect like in control center when you pull up too far
        NSInteger xDiff = abs(initialXOff - translatedPoint.x);
        if(initialXOff != translatedPoint.x) {
            
            translatedPoint.x += ((xDiff * .1) * (initialXOff < translatedPoint.x ? -1 : 1));
        }
        
        
        // Set the center
        [self setCenter:translatedPoint];
    }
    
    
    if(self.center.x < (minOff + (diff/3.f)))
    {
        self.shelfHeader.arrowState = OBHoverArrowStateRight;
    }
    else if(self.center.x > (maxOff - (diff/3.f)))
    {
        self.shelfHeader.arrowState = OBHoverArrowStateLeft;
    }
    else
    {
        self.shelfHeader.arrowState = OBHoverArrowStateFlat;
    }
    
    // Finished here
    if(pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateEnded)
    {
        CGFloat velocityX = (0.2*[pan velocityInView:self.superview].x);
        
        
        CGFloat finalX = translatedPoint.x + velocityX;
        CGFloat finalY = self.center.y;
        
        if(finalX < minOff + diff / 2.0f)
        {
            self.shelfHeader.arrowState = OBHoverArrowStateRight;
            finalX = minOff;
        }
        else
        {
            self.shelfHeader.arrowState = OBHoverArrowStateLeft;
            finalX = (self.superview.bounds.size.width - PEEK_LEVEL + self.bounds.size.width / 2);
        }
        
        CGFloat animationDuration = (ABS(velocityX)*.0002)+.2;
        
        [UIView animateWithDuration:animationDuration animations:^{
            [self setCenter:CGPointMake(finalX, finalY)];
        } completion:^(BOOL finished) {
            self.internalCollectionView.scrollEnabled = self.shelfHeader.arrowState == OBHoverArrowStateRight;
            if(self.shelfHeader.arrowState == OBHoverArrowStateLeft)
                [self _setupForCollapsed:false];
        }];
    }
    
    // Update the alpha of the background.
    // Should be (maxOff - minOff)
    CGFloat shadowAlpha = (self.center.x - maxOff) / (minOff) * -2.5f;
    CALayer * l = [_shadowOverlayView.layer.sublayers objectAtIndex:0];
    l.opacity = MIN(shadowAlpha, .7f); // = [[UIColor whiteColor] colorWithAlphaComponent:MIN(shadowAlpha, .5f)];
}

- (void)brandingDidClick
{
    if(self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}


- (void)tapToCloseMenu {
    [self collapseShelfWithFinishBlock:^(BOOL finished) {
        [self _setupForCollapsed:NO]; }];
}

#pragma mark - Getters

- (UIView *)shadowOverlayView
{
    if(!_shadowOverlayView)
    {
        _shadowOverlayView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];

        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseMenu)];
        tapRecognizer.numberOfTapsRequired = 1.f;
        tapRecognizer.numberOfTouchesRequired = 1.f;
        tapRecognizer.delegate = self;

        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        
        [_shadowOverlayView addGestureRecognizer:tapRecognizer];
        [_shadowOverlayView addGestureRecognizer:pan];
        
        _shadowOverlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        CALayer * l = [CALayer layer];
        l.frame = _shadowOverlayView.bounds;
        l.backgroundColor = [UIColor whiteColor].CGColor;
        l.opacity = 0.f;
        [_shadowOverlayView.layer addSublayer:l];
    }
    return _shadowOverlayView;
}

- (CGRect)hoverBounds
{
    // We want to subtract 100 so that we have some padding when we're pulling up.
    // This simulates the control center on ios
    return CGRectMake(0.0, 0, self.bounds.size.width + 0.0, self.bounds.size.height);
}


#pragma mark - Setters

- (void)setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse
{
    if([_recommendationResponse isEqual:recommendationResponse]) return;
    
    _recommendationResponse = recommendationResponse;
    
    self.shelfHeader.arrowState = OBHoverArrowStateLeft;
    [self.internalCollectionView reloadData];
//    [self.internalCollectionView scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, 10) animated:NO];
}


#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.recommendationResponse.recommendations.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifier";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColorFromRGB(0xF4F4F4) colorWithAlphaComponent:(0.94f)];

    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];

    CGRect frame = cell.contentView.frame;
    frame.size.height -= 2.0f;
    UIView *whiteBackground = [[UIView alloc] initWithFrame:frame];
    whiteBackground.backgroundColor = [UIColor whiteColor];
    whiteBackground.layer.masksToBounds = NO;
    whiteBackground.layer.contentsScale = [UIScreen mainScreen].scale;
    whiteBackground.layer.shadowOpacity = 0.75f;
    whiteBackground.layer.shadowRadius = 5.0f;
    whiteBackground.layer.shadowOffset = CGSizeZero;
    whiteBackground.layer.shadowPath = [UIBezierPath bezierPathWithRect:whiteBackground.bounds].CGPath;
    whiteBackground.layer.shouldRasterize = YES;
    [cell.contentView addSubview:whiteBackground];
    
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(IMAGE_VIEW_PADDING, IMAGE_VIEW_PADDING, cell.contentView.bounds.size.width - IMAGE_VIEW_PADDING * 2, IMAGE_VIEW_HEIGHT)];
    iv.contentMode = UIViewContentModeScaleAspectFill;
    iv.clipsToBounds = YES;
    iv.backgroundColor = [UIColor lightGrayColor];
    [whiteBackground addSubview:iv];
    typeof(iv) __weak __iv = iv;
    [self fetchImageForURL:recommendation.image.url withCallback:^(UIImage *image) {
        __iv.image = image;
    }];
    
    UILabel *titleLabel = [self getTitleLabelForText:recommendation.content toFitWidth:iv.frame.size.width];
    titleLabel.frame = CGRectMake(iv.frame.origin.x, CGRectGetMaxY(iv.frame), iv.frame.size.width, titleLabel.frame.size.height);
    [whiteBackground addSubview:titleLabel];
    
    
    UILabel * sourceLabel = [self getSourceLabelForText:recommendation.author?:recommendation.source toFitWidth:iv.frame.size.width];
    sourceLabel.frame = CGRectOffset(sourceLabel.frame, 0, CGRectGetMaxY(titleLabel.frame) + 5.0f);
    [whiteBackground addSubview:sourceLabel];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    cell.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    [cell bringSubviewToFront:cell.selectedBackgroundView];
    return cell;
}

- (UILabel *)getSourceLabelForText:(NSString *)text toFitWidth:(CGFloat)width {
    UILabel * sourceLabel = [UILabel new];
    sourceLabel.backgroundColor = [UIColor clearColor];
    sourceLabel.font = [UIFont systemFontOfSize:10.f];
    sourceLabel.textColor = [UIColor colorWithRed:0.933 green:0.506 blue:0.000 alpha:1.000];
    sourceLabel.text = [NSString stringWithFormat:@"(%@)",text];
    [sourceLabel sizeToFit];
    sourceLabel.frame = CGRectMake(IMAGE_VIEW_PADDING, 0, sourceLabel.frame.size.width, sourceLabel.frame.size.height);
    return sourceLabel;
}

- (UILabel *)getTitleLabelForText:(NSString *)text toFitWidth:(CGFloat)width {
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(IMAGE_VIEW_PADDING, 0, width, 0)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.contentMode = UIViewContentModeBottom;
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    titleLabel.text = text;
    [titleLabel sizeToFitFixedWidth:width];
    return titleLabel;
}

- (void)collapseShelfWithFinishBlock:(void (^)(BOOL))finishedBlock {
    [UIView animateWithDuration:.2f animations:^{
        [self.shelfHeader setArrowState:OBHoverArrowStateLeft];
        self.frame = CGRectOffset(self.bounds, CGRectGetMaxX(self.superview.bounds) - PEEK_LEVEL, STATUS_BAR_AND_NAVIGATION_BAR_TOP_PADDING);
    } completion:finishedBlock];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    [self collapseShelfWithFinishBlock:^(BOOL finished) {
        [self _setupForCollapsed:NO];
        OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
        if(self.recommendationTapHandler)
        {
            self.recommendationTapHandler(recommendation);
        }
        
        if([self.widgetDelegate respondsToSelector:@selector(widgetView:tappedRecommendation:)])
        {
            [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
        }
    }];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OBRecommendation *rec = self.recommendationResponse.recommendations[indexPath.row];

    UICollectionViewFlowLayout * l = (UICollectionViewFlowLayout *)collectionViewLayout;
    UILabel *titleLabel = [self getTitleLabelForText:rec.content toFitWidth:(collectionView.bounds.size.width - (l.sectionInset.right + l.sectionInset.left)) - IMAGE_VIEW_PADDING*2];
    UILabel *sourceLabel = [self getSourceLabelForText:rec.source?:rec.author toFitWidth:(collectionView.bounds.size.width - (l.sectionInset.right + l.sectionInset.left)) - IMAGE_VIEW_PADDING*2];

    return CGSizeMake(collectionView.bounds.size.width - (l.sectionInset.right + l.sectionInset.left), IMAGE_VIEW_HEIGHT + IMAGE_VIEW_PADDING * 4 + titleLabel.frame.size.height + sourceLabel.frame.size.height);
}

#pragma mark - Helpers

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

- (void)_setupForExpand
{
    if(self.superview == _shadowOverlayView) return;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(userWillExpandShelfView:)])
    {
        [self.delegate userWillExpandShelfView:self];
    }

    [self.superview addSubview:self.shadowOverlayView];
    self.shadowOverlayView.frame = self.superview.frame;
    self.frame = [self.superview convertRect:self.frame toView:_shadowOverlayView];
    // Here we'll setup ourself to be in the expanded state
    // Here we want to move ourself to the main window, and reset up everything
    _oldSuperView = self.superview;
    [self.shadowOverlayView addSubview:self];
    
    self.internalCollectionView.scrollEnabled = YES;
    
    if([_oldSuperView isKindOfClass:[UIScrollView class]])
    {
        [(UIScrollView *)_oldSuperView setScrollsToTop:NO];
    }
}

- (void)_setupForCollapsed:(BOOL)dismiss
{
    
    if(!_shadowOverlayView) return;
    
    // Just collapsing here.
    if(!dismiss && self.delegate && [self.delegate respondsToSelector:@selector(userDidCollapseShelfView:)])
    {
        [self.delegate userDidCollapseShelfView:self];
    }
    
    
    // Setup for collapsed (arrowUp state).
    self.frame = [_shadowOverlayView convertRect:self.frame toView:_oldSuperView];
    [_oldSuperView addSubview:self];
    [_shadowOverlayView removeFromSuperview];
    _shadowOverlayView = nil;
    if([_oldSuperView isKindOfClass:[UIScrollView class]])
    {
        [(UIScrollView *)_oldSuperView setScrollsToTop:YES];
    }
//    [self.internalCollectionView scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, 5) animated:YES];
    self.internalCollectionView.scrollEnabled = NO;
    
    
    // Fully dismissed off screen.
    if(dismiss && [self.delegate respondsToSelector:@selector(userDidDismissShelfView:)])
    {
        [self.delegate userDidDismissShelfView:self];
    }
}

@end


#define OBDarkOrange [UIColor colorWithRed:185/255.0 green:96/255.0 blue:0 alpha:1.000]
#define TRIANGLE_SIDE 15
#define LABEL_LEFT_PADDING 20
#define LABEL_TOP_PADDING 5
#define LEFT_RIGHT_CELL_MARGIN 10

@implementation OBShelfHeader
@synthesize ameliaHeaderHeight;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
        self.orangeContainer = [[UIView alloc] initWithFrame:CGRectMake(0,0,300,20)];
        self.orangeContainer.backgroundColor = [UIColor colorWithRed:0.914 green:0.506 blue:0.129 alpha:1.000];
        [self addSubview:self.orangeContainer];

        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,20)];
        self.headerLabel.text = @"FROM THE WEB";
        self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        [self.headerLabel sizeToFit];
        self.headerLabel.textColor = [UIColor whiteColor];
        [self.orangeContainer addSubview:self.headerLabel];
        
        self.brandingImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.brandingImageButton addTarget:self action:@selector(brandingDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.brandingImageButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
        CGRect r = CGRectMake(0, 0, 71, 18);
        r.origin.y = self.ameliaHeaderHeight;
        r.origin.x = (self.frame.size.width - r.size.width);
        self.brandingImageButton.frame = r;
        [self addSubview:self.brandingImageButton];
        
        [self.orangeContainer.layer addSublayer:self.arrowLayer];
        self.arrowLayer.position = CGPointMake(self.headerLabel.frame.origin.x + 20.0, CGRectGetMidY(self.headerLabel.frame) + LABEL_TOP_PADDING    );
        
        self.orangeContainer.frame = CGRectMake(0,0,self.arrowLayer.frame.size.width + LABEL_LEFT_PADDING*2 + self.headerLabel.frame.size.width, self.headerLabel.frame.size.height + LABEL_TOP_PADDING*2);
        self.headerLabel.frame = CGRectMake(self.arrowLayer.frame.size.width + LABEL_LEFT_PADDING, LABEL_TOP_PADDING, self.headerLabel.frame.size.width,self.headerLabel.frame.size.height);
        self.brandingImageButton.center = CGPointMake(self.brandingImageButton.center.x, CGRectGetMidY(self.orangeContainer.frame));
    }
    return self;
}

- (void)brandingDidClick {
    if (self.delegate && [self.delegate respondsToSelector:@selector(brandingDidClick)]) {
        [self.delegate brandingDidClick];
    }
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    float bottomLabel = CGRectGetMaxY(self.orangeContainer.frame);
    [path moveToPoint:CGPointMake(0, bottomLabel)];
    [path addLineToPoint:CGPointMake(TRIANGLE_SIDE, bottomLabel + 2*TRIANGLE_SIDE/3)];
    [path addLineToPoint:CGPointMake(TRIANGLE_SIDE, bottomLabel)];
    [path closePath];
    [OBDarkOrange set];
    [path fill];
}

- (CAShapeLayer *)arrowLayer
{
    if(!_arrowLayer)
    {
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.bounds = CGRectMake(0, 0, 20.f, ARROW_HEIGHT*2.f);
//        layer.position = CGPointMake(10.0f, (layer.bounds.size.height/2.f) + 5.f);
        layer.lineWidth = 4.f;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineCap = kCALineCapSquare;
        layer.lineJoin = kCALineJoinMiter;
        layer.masksToBounds = YES;
        
        // Make sure we don't animate the initial creation of the path.
        // It just looks weird
        _arrowLayer = layer;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        layer.path = [self _pathForArrowState:self.arrowState].CGPath;
        [CATransaction commit];
        _arrowLayer = layer;
    }
    return _arrowLayer;
}

- (void)setArrowState:(OBHoverArrowState)arrowState
{
    _arrowState = arrowState;
    
    CABasicAnimation * animatePath  = [CABasicAnimation animationWithKeyPath:@"path"];
    animatePath.toValue = (__bridge id)[self _pathForArrowState:arrowState].CGPath;
    animatePath.fillMode = kCAFillModeForwards;
    animatePath.removedOnCompletion = NO;
    animatePath.duration = .3f;
    [[self arrowLayer] addAnimation:animatePath forKey:nil];
}

- (UIBezierPath *)_pathForArrowState:(OBHoverArrowState)state
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    // Move to far left
    [path moveToPoint:CGPointMake(_arrowLayer.bounds.size.width/2.f, 0)];
    
    // The offset to move by
    CGFloat arrowOffset = state == OBHoverArrowStateRight ? _arrowLayer.bounds.size.width - 2.0f : 2.0f;
    if(state == OBHoverArrowStateFlat) arrowOffset = 5.0f;   // Flat line
    [path addLineToPoint:CGPointMake(arrowOffset, _arrowLayer.bounds.size.height/2.f)];
    
    // Far right
    [path addLineToPoint:CGPointMake(_arrowLayer.bounds.size.width/2.f, _arrowLayer.bounds.size.height)];
    
    return path;
}

@end

