//
//  JLoadingView.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/4/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLoadingView : UIImageView

+ (instancetype)showLoadingViewInView:(UIView *)view animated:(BOOL)animated;
+ (instancetype)showLoadingViewInView:(UIView *)view withDelay:(CGFloat)delay animated:(BOOL)animated;

/**
 *  How long to wait before hiding the loading view
 *  Defaults: HUGE_VALF
 **/
@property (nonatomic, assign) CGFloat waitTime;

- (void)dismiss;

@end
