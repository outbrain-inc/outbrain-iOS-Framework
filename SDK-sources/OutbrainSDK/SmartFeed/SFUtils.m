//
//  SFUtils.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFUtils.h"

@implementation SFUtils

+(void) addConstraintsToFillParent:(UIView *)view {
    UIView *parentView = view.superview;
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[view leadingAnchor] constraintEqualToAnchor:[parentView leadingAnchor] constant:0].active = YES;
    [[view trailingAnchor] constraintEqualToAnchor:[parentView trailingAnchor] constant:0].active = YES;
    [[view topAnchor] constraintEqualToAnchor:[parentView topAnchor] constant:0].active = YES;
    [[view bottomAnchor] constraintEqualToAnchor:[parentView bottomAnchor] constant:0].active = YES;
    
    [view setNeedsLayout];
    
    /*
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint
                                                 constraintWithItem:view attribute:NSLayoutAttributeLeft
                                                 relatedBy:NSLayoutRelationEqual toItem:parentView attribute:
                                                 NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint
                                          constraintWithItem:view attribute:NSLayoutAttributeRight
                                          relatedBy:NSLayoutRelationEqual toItem:parentView attribute:
                                          NSLayoutAttributeRight multiplier:1.0 constant:0];
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint
                                           constraintWithItem:view attribute:NSLayoutAttributeTop
                                           relatedBy:NSLayoutRelationEqual toItem:parentView attribute:
                                           NSLayoutAttributeTop multiplier:1.0 constant:0];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint
                                         constraintWithItem:view attribute:NSLayoutAttributeBottom
                                         relatedBy:NSLayoutRelationEqual toItem:parentView attribute:
                                         NSLayoutAttributeBottom multiplier:1.0 constant:0];
    
    [view addConstraints:@[leftConstraint, rightConstraint, topConstraint, bottomConstraint]];
     */
}

+(void) addHeightConstraint:(CGFloat) height toView:(UIView *)view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *heightConst = [NSLayoutConstraint
                                  constraintWithItem:view
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:nil
                                  attribute:NSLayoutAttributeNotAnAttribute
                                  multiplier:0
                                  constant:height];
    [view addConstraint:heightConst];
}

@end
