//
//  TinyPageControl.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIView.h>
#import <UIKit/UIColor.h>

// We use quarts for some of our stuff
#import <QuartzCore/CATransaction.h>
#import <QuartzCore/CAAnimation.h>
#import <QuartzCore/CALayer.h>


@interface TinyPageControl : UIControl

/**
 *  The current page that we're on.
 **/
@property (nonatomic, assign) NSInteger currentPage;

/**
 *  The number of pages that we should account for
 **/
@property (nonatomic, assign) NSInteger numberOfPages;

/**
 *  This is the total padding that you want between the indicators
 *  Defaults: 10.f
 **/
@property (nonatomic, assign) CGFloat padding;

/**
 *  The selected page indicator color.  The unselected page color
 *  will be this with a lower alpha
 **/
@property (nonatomic, strong) UIColor * pageIndicatorColor;

// The offset between indexes.  Example: 1.2
- (void)setCurrentPageOffsetPercentage:(CGFloat)percentage;

@end
