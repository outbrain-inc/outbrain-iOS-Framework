//
//  OBParalaxTitleView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBParalaxTitleView.h"

@implementation OBParalaxTitleView
{
    UIScrollView *_scrollContainer;
    
    CAGradientLayer * _leftGradient;
    CAGradientLayer * _rightGradient;
}


#pragma mark - Initialize

- (void)initialize
{
    self.userInteractionEnabled = NO;
    _scrollContainer = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 10.f)];
    _scrollContainer.showsHorizontalScrollIndicator = NO;
    _scrollContainer.scrollsToTop = NO;
    _scrollContainer.pagingEnabled = YES;
    _scrollContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:_scrollContainer];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _pageControl = [[TinyPageControl alloc] initWithFrame:CGRectMake(50.f, self.bounds.size.height - 6.f, self.bounds.size.width-100.f, 6.f)];
//    _pageControl.padding = 10.f;
    _pageControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:_pageControl];
    
    
    _leftGradient = [CAGradientLayer layer];
    _leftGradient.bounds = CGRectMake(0, 0, 30, self.bounds.size.height);
    _leftGradient.position = CGPointMake(15.f, self.bounds.size.height/2.f);
    _leftGradient.locations = @[@(0.0),@(1.f)];
    _leftGradient.startPoint = CGPointMake(0, .5f);
    _leftGradient.endPoint = CGPointMake(1.f,.5f);
    [self.layer addSublayer:_leftGradient];
    
    _rightGradient = [CAGradientLayer layer];
    _rightGradient.bounds = CGRectMake(0, 0, 30, self.bounds.size.height);
    _rightGradient.position = CGPointMake(self.bounds.size.width - 15.f, self.bounds.size.height/2.f);
    _rightGradient.locations = @[@(0.f),@(1.f)];
    _rightGradient.startPoint = CGPointMake(1.f, .5f);
    _rightGradient.endPoint = CGPointMake(0.f,.5f);
    [self.layer addSublayer:_rightGradient];
    
    UIColor * gray = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.000];;
    _leftGradient.colors =
    _rightGradient.colors = @[(id)gray.CGColor,(id)[gray colorWithAlphaComponent:.1f].CGColor];
    
    _rightGradient.contentsScale = _leftGradient.contentsScale = [[UIScreen mainScreen] scale];
}

- (id)initWithFrame:(CGRect)frame{if((self=[super initWithFrame:frame]))[self initialize]; return self;}
- (id)initWithCoder:(NSCoder *)aDecoder{if((self=[super initWithCoder:aDecoder]))[self initialize]; return self;}


#pragma mark - Setters

- (void)setDarkStyle:(BOOL)darkStyle
{
    if(darkStyle == _darkStyle) return;
    _darkStyle = darkStyle;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if(darkStyle)
    {
        _leftGradient.colors =
        _rightGradient.colors = @[(id)[UIColor blackColor].CGColor,(id)[[UIColor blackColor] colorWithAlphaComponent:.1f].CGColor];
    }
    else
    {
        _leftGradient.colors =
        _rightGradient.colors = @[(id)[UIColor whiteColor].CGColor,(id)[[UIColor whiteColor] colorWithAlphaComponent:.1f].CGColor];
    }
    [CATransaction commit];
}

- (void)setTitles:(NSArray *)titles
{
    if([titles isEqual:_titles]) return;
    _titles = [titles copy];
    
    // Clear all of the current subviews
    [[_scrollContainer subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];

    NSInteger index = 0;
    for(NSString * title in titles)
    {
        UILabel * l = [[UILabel alloc] initWithFrame:CGRectOffset(self.bounds, self.bounds.size.width*index, -5)];
        
        l.text = [title isKindOfClass:[NSNull class]]?@"Recommended to you":title;
        l.font = [UIFont systemFontOfSize:12];
        l.textColor = OBOrange;
        l.textAlignment = NSTextAlignmentCenter;
        l.tag = 100 + index;
        [_scrollContainer addSubview:l];
        index++;
    }
    
    _scrollContainer.contentSize = CGSizeMake(_titles.count * _scrollContainer.frame.size.width, 0);
}

- (void)setCurrentOffset:(CGFloat)offset
{
    CGFloat currentOffset = offset;
    [self.pageControl setCurrentPageOffsetPercentage:currentOffset];
    
    CGFloat modifier = 1.3f;
    
    CGFloat xOffForCurrentIndex = _scrollContainer.frame.size.width * _pageControl.currentPage;
    CGFloat inBetweenOffset = (_scrollContainer.frame.size.width * ((offset - _pageControl.currentPage) * modifier));
    CGFloat toX = (xOffForCurrentIndex + inBetweenOffset);

//    CGFloat toX = (offset * modifier) * _scrollContainer.frame.size.width;
    toX = MAX((xOffForCurrentIndex - _scrollContainer.frame.size.width), toX);
    toX = MIN((xOffForCurrentIndex + _scrollContainer.frame.size.width), toX);
    
    [_scrollContainer setContentOffset:CGPointMake(toX, _scrollContainer.contentOffset.y)];
}

- (void)setCurrentIndex:(NSInteger)index
{
    _pageControl.currentPage = index;
    [_scrollContainer setContentOffset:CGPointMake(index*_scrollContainer.frame.size.width, 0) animated:YES];
}

@end
