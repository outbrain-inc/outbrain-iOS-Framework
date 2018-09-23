//
//  SFUtils.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation SFUtils

+(void) addConstraintsToFillParent:(UIView *)view {
    UIView *parentView = view.superview;
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [[view leadingAnchor] constraintEqualToAnchor:[parentView leadingAnchor] constant:0].active = YES;
    [[view trailingAnchor] constraintEqualToAnchor:[parentView trailingAnchor] constant:0].active = YES;
    [[view topAnchor] constraintEqualToAnchor:[parentView topAnchor] constant:0].active = YES;
    [[view bottomAnchor] constraintEqualToAnchor:[parentView bottomAnchor] constant:0].active = YES;
    
    [view setNeedsLayout];
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

// https://stackoverflow.com/questions/39624675/add-shadow-on-uiview-using-swift-3
+(void) addDropShadowToView:(UIView *)view {
    CALayer *layer = view.layer;
    layer.masksToBounds = NO;
    layer.shadowColor = [[UIColor blackColor] CGColor];
    layer.shadowOpacity = 0.5;
    layer.shadowOffset = CGSizeMake(-1, 1);
    layer.shadowRadius = 1;
    layer.shadowPath = [[UIBezierPath bezierPathWithRect:view.bounds] CGPath];
    layer.shouldRasterize = YES;
    layer.zPosition = 1;
    layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
