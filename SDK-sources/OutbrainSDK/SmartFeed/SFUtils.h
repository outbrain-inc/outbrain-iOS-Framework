//
//  SFUtils.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@protocol SFClickListener

- (void) recommendationClicked: (id)sender;
- (void) adChoicesClicked:(id)sender;
- (void) outbrainLabelClicked:(id)sender;

@end

@interface SFUtils : NSObject

+(void) addConstraintsToFillParent:(UIView *)view;

+(void) addHeightConstraint:(CGFloat) height toView:(UIView *)view;

+(void) addDropShadowToView:(UIView *)view;

@end
