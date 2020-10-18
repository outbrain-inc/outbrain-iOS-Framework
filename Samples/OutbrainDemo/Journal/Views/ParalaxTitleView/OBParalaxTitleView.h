//
//  OBParalaxTitleView.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/3/14.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import <UIKit/UIControl.h>
#import <QuartzCore/CAGradientLayer.h>

#import "TinyPageControl.h"

@interface OBParalaxTitleView : UIView

// Determines if we are on a light or dark background
@property (nonatomic, assign) BOOL darkStyle;

@property (nonatomic, copy) NSArray * titles;

/**
 *
 **/
@property (nonatomic, strong, readonly) TinyPageControl * pageControl;

/**
 *  The current index that we're on now
 **/
@property (nonatomic, assign) NSInteger currentIndex;

/**
 *  Use this to do the interactive offsets. 
 *  E.g  1.2f
 **/
- (void)setCurrentOffset:(CGFloat)offset;
@end
