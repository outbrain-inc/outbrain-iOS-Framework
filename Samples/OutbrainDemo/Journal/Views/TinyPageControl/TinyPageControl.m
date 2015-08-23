//
//  TinyPageControl.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "TinyPageControl.h"

#define MIN_UNSELECTED_ALPHA    .2f

@interface TinyPageControl ()

@property (nonatomic, strong) UIView * pageIndicatorContainerView;

@end

@implementation TinyPageControl

#pragma mark - Initialize

- (void)initialize
{
    self.pageIndicatorContainerView = [[UIView alloc] initWithFrame:self.bounds];
    _pageIndicatorContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_pageIndicatorContainerView];
    
    
    self.pageIndicatorColor = [UIColor blackColor];
    self.padding = 2.f;
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self initialize]; return self; }
- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self initialize]; return self; }


#pragma mark - Setup

- (CALayer *)_newTickLayer
{
    CALayer * l = [CALayer new];
    l.contentsScale = l.rasterizationScale = [[UIScreen mainScreen] scale];
    
    if([[[UIDevice currentDevice] systemVersion] intValue] >= 7)
    {
        [l setValue:@(YES) forKey:@"allowsEdgeAntialiasing"];
    }
    else
    {
        l.edgeAntialiasingMask = kCALayerBottomEdge | kCALayerLeftEdge | kCALayerRightEdge | kCALayerTopEdge;
    }
    l.shouldRasterize = YES;
    l.bounds = CGRectMake(0,0,0, self.pageIndicatorContainerView.frame.size.height - 4);
    l.cornerRadius = l.bounds.size.height/2.f;
    l.backgroundColor = _pageIndicatorColor.CGColor;
    
    return l;
}

- (void)_setupPageDots
{
    [_pageIndicatorContainerView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat tickWidthWithPadding = _pageIndicatorContainerView.frame.size.height;
    
    CGFloat curXOff = 0;
    for(int i = 0; i < _numberOfPages; i++)
    {
        @autoreleasepool {
            CALayer * l = [self _newTickLayer];
            l.frame = CGRectMake(curXOff, (self.pageIndicatorContainerView.frame.size.height - l.bounds.size.height) / 2.f, tickWidthWithPadding, l.bounds.size.height);
            [_pageIndicatorContainerView.layer addSublayer:l];
            
            l.backgroundColor = (i == _currentPage) ? [self pageIndicatorColor].CGColor : [[self pageIndicatorColor] colorWithAlphaComponent:MIN_UNSELECTED_ALPHA].CGColor;
            
            curXOff = CGRectGetMaxX(l.frame) + (_padding/2.f);
        }
    }
    [self updateStateForLayerAtIndex:_currentPage];
}


#pragma mark - Helpers

- (CALayer *)ticLayerForIndex:(NSInteger)index
{
    if(index < 0) return nil;
    if(index >= [_pageIndicatorContainerView.layer.sublayers count]) return nil;
    return (CALayer *)[_pageIndicatorContainerView.layer sublayers][index];
}

- (void)updateStateForLayerAtIndex:(NSInteger)index
{
    BOOL selected = (index == _currentPage);
    CALayer * l = [self ticLayerForIndex:index];
    l.backgroundColor = (selected) ? [self pageIndicatorColor].CGColor : [[self pageIndicatorColor] colorWithAlphaComponent:MIN_UNSELECTED_ALPHA].CGColor;
    
    
    CGFloat offset = selected ? -M_PI_2 : 0;
    if(index < _currentPage)
        offset = -offset;
    
    
    
    CABasicAnimation * a = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    a.toValue = @(offset);
    a.removedOnCompletion = NO;
    a.fillMode = kCAFillModeForwards;
    [l addAnimation:a forKey:nil];
}


#pragma mark - Setters

//- (void)setFrame:(CGRect)frame
//{
//    BOOL relayout = (frame.size.height != self.frame.size.height);
//    [super setFrame:frame];
//    if(relayout)
//    {
//        [self _setupPageDots];
//        [self updateStateForLayerAtIndex:_currentPage];
//    }
//}

- (void)setNumberOfPages:(NSInteger)numberOfPages
{
    if(_numberOfPages == numberOfPages) return;
    
    _numberOfPages = numberOfPages;
    [self _setupPageDots];
}

- (void)setCurrentPage:(NSInteger)currentPage
{
//    if(_currentPage == currentPage) return;
    
    NSInteger old = _currentPage;
    _currentPage = currentPage;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:.1f];
    
    [CATransaction setCompletionBlock:^{
        for(CALayer * l in _pageIndicatorContainerView.layer.sublayers)
        {
            if(l != [self ticLayerForIndex:_currentPage])
                [l removeAllAnimations];
        }
    }];
    
    [self updateStateForLayerAtIndex:old];
    [self updateStateForLayerAtIndex:currentPage];
    
    [CATransaction commit];
}

- (void)setCurrentPageOffsetPercentage:(CGFloat)percentage
{
    NSInteger index = (_currentPage < percentage) ? _currentPage+1 : _currentPage-1;
    
    CALayer * currentLayer = [self ticLayerForIndex:_currentPage];
    CALayer * nextLayer = [self ticLayerForIndex:index];
    
    CGFloat percentageAwayFromCurrentPage = roundf(fabs((float)_currentPage - percentage) * 100.f) / 100.f;
    
    currentLayer.backgroundColor = [[self pageIndicatorColor] colorWithAlphaComponent:MAX(MIN_UNSELECTED_ALPHA, 1.f - percentageAwayFromCurrentPage)].CGColor;
    nextLayer.backgroundColor = [[self pageIndicatorColor] colorWithAlphaComponent:MAX(percentageAwayFromCurrentPage, MIN_UNSELECTED_ALPHA)].CGColor;
    
    
    CGFloat offset = -(M_PI_2 * (1.f - percentageAwayFromCurrentPage));
    if(index < _currentPage)
    {
        // Moving left
        offset = -(M_PI_2 - (M_PI_2 * percentageAwayFromCurrentPage));
    }
    CABasicAnimation * a = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    a.toValue = @(offset);
    a.duration = .1f;
    a.removedOnCompletion = NO;
    a.fillMode = kCAFillModeForwards;
    [currentLayer addAnimation:a forKey:nil];
    
    offset = -(M_PI_2 * percentageAwayFromCurrentPage);
    if(index < _currentPage)
    {
        offset = -(M_PI_2 - (M_PI_2 * (1.f - percentageAwayFromCurrentPage)));
    }
    a.toValue = @(offset);
    [nextLayer addAnimation:a forKey:nil];
}

@end
