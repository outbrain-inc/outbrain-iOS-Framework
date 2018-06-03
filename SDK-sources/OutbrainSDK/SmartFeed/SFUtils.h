//
//  SFUtils.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SFUtils : NSObject

+(void) addConstraintsToFillParent:(UIView *)view;

+(void) addHeightConstraint:(CGFloat) height toView:(UIView *)view;

+(void) addDropShadowToView:(UIView *)view;

@end
