//
//  OBHoverView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBAdhesionView.h"
#import "OBDemoDataHelper.h"

#import <OutbrainSDK/OutbrainSDK.h>

#define ARROW_HEIGHT 9.f
#define BOTTOM_PADDING_AMOUNT 100.f // Some padding to go to the bottom for when we're `tugging` up


@interface StickyHeaderFlowLayout : UICollectionViewFlowLayout @end

@interface OBAdhesionView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
{
    BOOL _appliedPadding;
    UIView * _oldSuperView;
}
@property (nonatomic, strong) UIView * shadowOverlayView;
/**
 *  Mimic the control center arrow
 **/
@property (nonatomic, strong) CAShapeLayer * arrowLayer;

/**
 *  Internal scroll container
 **/
@property (nonatomic, strong) UICollectionView * internalCollectionView;

@end

@implementation OBAdhesionView


#pragma mark - Initialize

- (void)commonInit
{
    self.backgroundColor = [UIColorFromRGB(0xF4F4F4) colorWithAlphaComponent:.95f];
    
    self.arrowState = OBHoverArrowStateUp;
    
    UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    tapRecognizer.numberOfTapsRequired = 1.f;
    tapRecognizer.numberOfTouchesRequired = 1.f;
    tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    
    self.peekAmount = 82.f;
    
    // Setup our collection view
    CGRect contentRect = [self hoverBounds];
    CGFloat sideMargin = 10.f;
    CGFloat topBottomMargin = 9.f;
    
    UICollectionViewFlowLayout * layout = [StickyHeaderFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(3.f, sideMargin, topBottomMargin, sideMargin);
    layout.itemSize = CGSizeMake(contentRect.size.width - (sideMargin*2.f), (self.peekAmount - CGRectGetMaxY(self.arrowLayer.frame) - (topBottomMargin)));
    
    UICollectionView * cv = [[UICollectionView alloc] initWithFrame:contentRect collectionViewLayout:layout];
    cv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    cv.delegate = self;
    cv.dataSource = self;
    cv.backgroundColor = self.backgroundColor;
    cv.scrollEnabled = NO;
    [self addSubview:cv];
    
    [cv registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CellIdentifier"];
    [cv registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BrandingIdentifier"];
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
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        return NO;
    
    return (otherGestureRecognizer.view == self.internalCollectionView);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        UICollectionReusableView * v = [self.internalCollectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"BrandingIdentifier" forIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        if(CGRectContainsPoint(v.frame, [touch locationInView:self.internalCollectionView]))
        {
            self.internalCollectionView.scrollEnabled = NO;
            return YES;
        }
        return self.arrowState == OBHoverArrowStateUp;
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        // Check if our tap gesture is within our arrowLayer.
        if(CGRectContainsPoint(self.arrowLayer.frame, [gestureRecognizer locationInView:self]))
        {
            return YES;
        }
//        if(CGRectContainsPoint([self dismissRect], [gestureRecognizer locationInView:self]))
//        {
//            return YES;
//        }
    }
    else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        return YES;
    }
    if (self.arrowState == OBHoverArrowStateDown) {
        if(!CGRectContainsPoint(self.frame, [gestureRecognizer locationInView:self.window.rootViewController.view]))
            return YES;
    }

    return NO;
}

- (void)tapAction:(UITapGestureRecognizer *)tapper
{
    if(self.arrowState == OBHoverArrowStateDown)
    {
        if(self.delegate && [self.delegate respondsToSelector:@selector(userWillCollapseAdhesionView:)])
        {
            [self.delegate userWillCollapseAdhesionView:self];
        }
        // Animate down
        self.arrowState = OBHoverArrowStateUp;
        CALayer * l = [_shadowOverlayView.layer.sublayers firstObject];
        CABasicAnimation * a = [CABasicAnimation animationWithKeyPath:@"opacity"];
        a.fromValue = @(l.opacity);
        a.toValue = @0.f;
        a.duration = .3f;
        [l addAnimation:a forKey:nil];
        l.opacity = .0f;
        
        [UIView animateWithDuration:.25f animations:^{
            self.frame = CGRectOffset(self.bounds, 0,CGRectGetMaxY(self.superview.bounds) - self.peekAmount);
        } completion:^(BOOL finished) {
            [self _setupForCollapsed:NO];
        }];
    }
    else if(self.arrowState == OBHoverArrowStateUp)
    {
        // Animate Up
        self.arrowState = OBHoverArrowStateDown;
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
                             self.frame = CGRectOffset(self.bounds, 0, CGRectGetMaxY(self.shadowOverlayView.bounds) - [self hoverBounds].size.height);
                         } completion:^(BOOL finished) {
                             if(self.delegate && [self.delegate respondsToSelector:@selector(userDidExpandAdhesionView:)])
                             {
                                 [self.delegate userDidExpandAdhesionView:self];
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
    CGFloat minOff = (CGRectGetMaxY(self.superview.bounds) - [self hoverBounds].size.height) + ([self bounds].size.height/2.f);
    CGFloat maxOff = (CGRectGetMaxY(self.superview.bounds) - self.peekAmount) + ([self bounds].size.height/2.f);
    CGFloat diff = (maxOff - minOff);
    
    // Here we want the user to be able to slide up/down our outbrain hover view
    if(pan.state == UIGestureRecognizerStateBegan)
    {
        // Reset the start point everytime we begin touching
        startPoint = self.center;
    }
    
    // Adjust the translatedPoint based on our start offset.
    // We are only changing the y value here
    translatedPoint = CGPointMake(startPoint.x, startPoint.y + translatedPoint.y);
    
    CGFloat initialYOff = translatedPoint.y;
    translatedPoint.y = MAX(translatedPoint.y, minOff);
    
    if(pan.state == UIGestureRecognizerStateChanged)
    {
        
        // This gives us the pulling effect like in control center when you pull up too far
        NSInteger yDiff = fabs(initialYOff - translatedPoint.y);
        if(initialYOff != translatedPoint.y) {
            
            translatedPoint.y += ((yDiff * .1) * (initialYOff < translatedPoint.y ? -1 : 1));
        }
        
        // Set the center
        [[pan view] setCenter:translatedPoint];
    }
    
    
    if(self.center.y < (minOff + (diff/3.f)))
    {
        self.arrowState = OBHoverArrowStateDown;
    }
    else if(self.center.y > (maxOff - (diff/3.f)))
    {
        self.arrowState = OBHoverArrowStateUp;
    }
    else
    {
        self.arrowState = OBHoverArrowStateFlat;
    }
    
    // Finished here
    if(pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed || pan.state == UIGestureRecognizerStateEnded)
    {
        CGFloat velocityY = (0.2*[pan velocityInView:[pan view].superview].y);
        
        
        CGFloat finalX = startPoint.x;
        CGFloat finalY = translatedPoint.y + velocityY;
        
        if(finalY < (minOff + (diff / 2.f)))
        {
            self.arrowState = OBHoverArrowStateDown;
            finalY = minOff;
        }
        else
        {
            self.arrowState = OBHoverArrowStateUp;
            finalY = (CGRectGetMaxY(self.superview.bounds)) + ([pan view].bounds.size.height / 2.f);
        }
        
        CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
        
        // Here we started in the expanded state.  We should not drop off completely here.
        // We should instead just reset to the max off
        BOOL shouldDropCompletely = (velocityY > 0 && startPoint.y >= maxOff && self.arrowState != OBHoverArrowStateDown);
        
        if(!shouldDropCompletely && self.arrowState != OBHoverArrowStateDown)
        {
            // If we are swiping down from the expanded state.  Then we should just
            // go back to the peek mode here.
            finalY = maxOff;
        }
        
        [UIView animateWithDuration:animationDuration animations:^{
            [[pan view] setCenter:CGPointMake(finalX, finalY)];
        } completion:^(BOOL finished) {
            self.internalCollectionView.scrollEnabled = self.arrowState == OBHoverArrowStateDown;
            if(self.arrowState == OBHoverArrowStateUp)
                [self _setupForCollapsed:shouldDropCompletely];
        }];
    }
    
    // Update the alpha of the background.
    // Should be (maxOff - minOff)
    CGFloat shadowAlpha = 1.f - ((self.center.y - minOff) / (maxOff - minOff));
    CALayer * l = [_shadowOverlayView.layer.sublayers objectAtIndex:0];
    l.opacity = MIN(shadowAlpha, .7f); // = [[UIColor whiteColor] colorWithAlphaComponent:MIN(shadowAlpha, .5f)];
}

- (void)brandingTapAction:(id)sender
{
    if(self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}


#pragma mark - Getters

- (CAShapeLayer *)arrowLayer
{
    if(!_arrowLayer)
    {
        CAShapeLayer * layer = [CAShapeLayer layer];
        layer.contentsScale = [[UIScreen mainScreen] scale];
        layer.bounds = CGRectMake(0, 0, 31.f, ARROW_HEIGHT*2.f);
        layer.position = CGPointMake(self.bounds.size.width/2, (layer.bounds.size.height/2.f) + 5.f);
        layer.lineWidth = 4.f;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = UIColorFromRGB(0x9A9A9A).CGColor;
        layer.lineCap = kCALineCapSquare;
        layer.lineJoin = kCALineJoinMiter;
        layer.masksToBounds = YES;
        
        // Make sure we don't animate the initial creation of the path.
        // It just looks weird
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        layer.path = [self _pathForArrowState:self.arrowState].CGPath;
        [CATransaction commit];
        _arrowLayer = layer;
    }
    return _arrowLayer;
}

- (UIView *)shadowOverlayView
{
    if(!_shadowOverlayView)
    {
        _shadowOverlayView = [[UIView alloc] initWithFrame:self.window.rootViewController.view.bounds];
        
        UITapGestureRecognizer * tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToCloseMenu)];
        tapRecognizer.numberOfTapsRequired = 1.f;
        tapRecognizer.numberOfTouchesRequired = 1.f;
        tapRecognizer.delegate = self;
        [_shadowOverlayView addGestureRecognizer:tapRecognizer];
        
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
    return CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - BOTTOM_PADDING_AMOUNT);
}


#pragma mark - Setters

- (void)setFrame:(CGRect)frame
{
    if(!_appliedPadding)
    {
        // Here we want to apply some padding so when the user tries to pull up to far
        // We have something for them to see.  Similar to control center.
        frame.size.height += BOTTOM_PADDING_AMOUNT;
        _appliedPadding = YES;
    }
    CGRect bounds = frame;
    bounds.origin = CGPointZero;
    BOOL boundsChange = !CGRectEqualToRect(bounds, self.bounds);
    
    if(boundsChange) [self.internalCollectionView.collectionViewLayout invalidateLayout];
    [super setFrame: frame];
    if(boundsChange) [self.internalCollectionView reloadData];
}

- (void)setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse
{
    if([_recommendationResponse isEqual:recommendationResponse]) return;

    _recommendationResponse = recommendationResponse;
    
    self.arrowState = OBHoverArrowStateUp;
    [self.internalCollectionView reloadData];
    [self.internalCollectionView scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, 10) animated:NO];
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


#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.recommendationResponse.recommendations.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if(![kind isEqualToString:UICollectionElementKindSectionHeader]) return nil;
    if(indexPath.section != 0) return nil;
    UICollectionReusableView * v = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"BrandingIdentifier" forIndexPath:indexPath];
    
    UIView * container = (UIView *)[v viewWithTag:100];
    UIButton * brandingImageButton = (UIButton *) [container viewWithTag:201];
    if(!container)
    {
        // Haven't setup this header yet
        v.backgroundColor = container.backgroundColor = self.backgroundColor;
        CGSize headerSize = [self collectionView:collectionView layout:collectionView.collectionViewLayout referenceSizeForHeaderInSection:indexPath.section];
        container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, headerSize.width, headerSize.height)];
        container.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        container.tag = 100;
        [v addSubview:container];
        
        // HIGHLIGHT LINE
        UIView * highlightLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, container.bounds.size.width, 1.f)];
        highlightLine.backgroundColor = [UIColor colorWithRed:0.824 green:0.824 blue:0.824 alpha:1.000];
        highlightLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [container addSubview:highlightLine];
        
        UILabel * alsoOnWeb = [UILabel new];
        alsoOnWeb.backgroundColor = [UIColor clearColor];
        alsoOnWeb.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.000];
        alsoOnWeb.font = [UIFont boldSystemFontOfSize:12];
        alsoOnWeb.text = @"Recommended to you";
        [alsoOnWeb sizeToFit];
        alsoOnWeb.center = CGPointMake(10.f + (alsoOnWeb.frame.size.width/2.f), container.bounds.size.height / 2.f);
        [container addSubview:alsoOnWeb];
        
        [container.layer addSublayer:self.arrowLayer];
        
        brandingImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        brandingImageButton.tag = 201;
        [brandingImageButton addTarget:self action:@selector(brandingTapAction:) forControlEvents:UIControlEventTouchUpInside];
        brandingImageButton.contentMode = UIViewContentModeScaleAspectFill;
        [brandingImageButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
        CGRect r = CGRectMake(0, 0, 71, 15);
        r.origin.y = (container.frame.size.height - r.size.height) / 2.f;
        r.origin.x = (container.frame.size.width - r.size.width - 5.f);
        brandingImageButton.frame = r;
        [container addSubview:brandingImageButton];
    }
    
    _arrowLayer.position = CGPointMake(collectionView.bounds.size.width / 2.f, container.bounds.size.height / 2.f);
    
    CGRect r = CGRectMake(0, 0, 71, 20);
    r.origin.y = (container.frame.size.height - r.size.height) / 2.f;
    r.origin.x = (container.frame.size.width - r.size.width - 5.f);
    brandingImageButton.frame = r;
    
    return v;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CellIdentifier";
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
    
    UIImageView * iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.bounds.size.height, cell.contentView.bounds.size.height)];
    iv.backgroundColor = [UIColor lightGrayColor];
    [cell.contentView addSubview:iv];
    typeof(iv) __weak __iv = iv;
    [OBDemoDataHelper fetchImageWithURL:recommendation.image.url withCallback:^(UIImage *image) {
        __iv.image = image;
    }];
    
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(iv.frame) + 5.f, -2.f, cell.contentView.bounds.size.width - iv.frame.size.width - 10.f, cell.contentView.bounds.size.height)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.contentMode = UIViewContentModeBottom;
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    titleLabel.text = recommendation.content;
    [cell.contentView addSubview:titleLabel];
    [titleLabel sizeToFit];
    
    
    UILabel * sourceLabel = [UILabel new];
    sourceLabel.backgroundColor = [UIColor clearColor];
    sourceLabel.font = [UIFont systemFontOfSize:10.f];
    sourceLabel.textColor = [UIColor colorWithRed:0.933 green:0.506 blue:0.000 alpha:1.000];
    sourceLabel.text = [NSString stringWithFormat:@"(%@)",(recommendation.source ? recommendation.source : recommendation.author)];
    [cell.contentView addSubview:sourceLabel];
    [sourceLabel sizeToFit];
    sourceLabel.frame = CGRectMake(CGRectGetMinX(titleLabel.frame), CGRectGetMaxY(titleLabel.frame), sourceLabel.frame.size.width, sourceLabel.frame.size.height);
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.contentView.bounds];
    cell.selectedBackgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    
    [cell bringSubviewToFront:cell.selectedBackgroundView];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    [self collapseDrawerWithFinishBlock:^(BOOL finished) {
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(collectionView.bounds.size.width, 25.f);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout * l = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGSize sectionSize = [self collectionView:collectionView layout:collectionViewLayout referenceSizeForHeaderInSection:indexPath.section];
    return CGSizeMake(collectionView.bounds.size.width - (l.sectionInset.right + l.sectionInset.left), (self.peekAmount - sectionSize.height - [(UICollectionViewFlowLayout *)collectionViewLayout minimumLineSpacing]));
}


#pragma mark - Helpers

- (UIBezierPath *)_pathForArrowState:(OBHoverArrowState)state
{
    UIBezierPath * path = [UIBezierPath bezierPath];
    
    // Move to far left
    [path moveToPoint:CGPointMake(-2.f, _arrowLayer.bounds.size.height/2.f)];

    // The offset to move by
    CGFloat arrowOffset = state == OBHoverArrowStateDown ? 5.f : -5.f;
    if(state == OBHoverArrowStateFlat) arrowOffset = 0.f;   // Flat line
    [path addLineToPoint:CGPointMake(_arrowLayer.bounds.size.width/2.f, (_arrowLayer.bounds.size.height/2.f) + arrowOffset)];
    
    // Far right
    [path addLineToPoint:CGPointMake(_arrowLayer.bounds.size.width+2.f, (_arrowLayer.bounds.size.height/2.f))];
    
    return path;
}

- (void)_setupForExpand
{
    if(self.superview == _shadowOverlayView) return;
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(userWillExpandAdhesionView:)])
    {
        [self.delegate userWillExpandAdhesionView:self];
    }
    
    [self.window.rootViewController.view addSubview:self.shadowOverlayView];
    self.shadowOverlayView.frame = self.window.rootViewController.view.bounds;
    self.frame = [self.superview convertRect:self.frame toView:_shadowOverlayView];
    
    // Here we'll setup ourself to be in the expanded state
    // Here we want to move ourself to the main window, and reset up everything
    _oldSuperView = self.superview;
    [_shadowOverlayView addSubview:self];
    
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
    if(!dismiss && self.delegate && [self.delegate respondsToSelector:@selector(userDidCollapseAdhesionView:)])
    {
        [self.delegate userDidCollapseAdhesionView:self];
    }
    
    
    // Setup for collapsed (arrowUp state).
    self.frame = [_shadowOverlayView convertRect:self.frame toView:_oldSuperView];
    [_shadowOverlayView removeFromSuperview];
    _shadowOverlayView = nil;
    [_oldSuperView addSubview:self];
    if([_oldSuperView isKindOfClass:[UIScrollView class]])
    {
        [(UIScrollView *)_oldSuperView setScrollsToTop:YES];
    }
    [self.internalCollectionView scrollRectToVisible:CGRectMake(0, 0, self.bounds.size.width, 5) animated:YES];
    self.internalCollectionView.scrollEnabled = NO;
    
    
    // Fully dismissed off screen.
    if(dismiss && [self.delegate respondsToSelector:@selector(userDidDismissAdhesionView:)])
    {
        [self.delegate userDidDismissAdhesionView:self];
    }
}

- (void)tapToCloseMenu {
    [self collapseDrawerWithFinishBlock:^(BOOL finished) {
        [self _setupForCollapsed:NO]; }];
}

- (void)collapseDrawerWithFinishBlock:(void (^)(BOOL))finishedBlock {
    [self setArrowState:OBHoverArrowStateUp];
    [UIView animateWithDuration:.2f animations:^{
        self.frame = CGRectOffset(self.bounds, 0, CGRectGetMaxY(self.superview.bounds) - self.peekAmount);
    } completion:finishedBlock];
}

@end





/**
 *  This is our sticky layout.  Telling our internalCollection view to keep the "Recommended to you" 
 *  at the top tableview style
 **/

@implementation StickyHeaderFlowLayout

- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    for (NSUInteger idx=0; idx<[answer count]; idx++) {
        UICollectionViewLayoutAttributes *layoutAttributes = answer[idx];
        
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];  // remember that we need to layout header for this section
        }
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [answer removeObjectAtIndex:idx];  // remove layout of header done by our super, we will do it right later
            idx--;
        }
    }
    
    // layout all headers needed for the rect using self code
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (layoutAttributes != nil) {
            [answer addObject:layoutAttributes];
        }
    }];
    
    return answer;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionView * const cv = self.collectionView;
        CGPoint const contentOffset = cv.contentOffset;
        CGPoint nextHeaderOrigin = CGPointMake(INFINITY, INFINITY);
        
        if (indexPath.section+1 < [cv numberOfSections]) {
            UICollectionViewLayoutAttributes *nextHeaderAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.section+1]];
            nextHeaderOrigin = nextHeaderAttributes.frame.origin;
        }
        
        CGRect frame = attributes.frame;
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
            frame.origin.y = contentOffset.y;
        }
        else { // UICollectionViewScrollDirectionHorizontal
            frame.origin.x = MIN(MAX(contentOffset.x, frame.origin.x), nextHeaderOrigin.x - CGRectGetWidth(frame));
        }
        attributes.zIndex = 1024;
        attributes.frame = frame;
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    return attributes;
}
- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self layoutAttributesForSupplementaryViewOfKind:kind atIndexPath:indexPath];
    return attributes;
}

- (BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end

