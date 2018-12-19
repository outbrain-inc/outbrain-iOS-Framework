//
//  SFUtils.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import WebKit;

#import "SFItemData.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define SPONSORED_LABEL_TAG 334422

@protocol SFVideoCellType

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, strong) SFItemData *sfItem;

@end


@protocol SFClickListener

- (void) recommendationClicked: (id)sender;
- (void) adChoicesClicked:(id)sender;
- (void) outbrainLabelClicked:(id)sender;

@end

@interface SFUtils : NSObject

+(void) addConstraintsToFillParent:(UIView *)view;

+(void) addConstraintsToFillParentWithHorizontalMargin:(UIView *)view;

+(void) addDropShadowToView:(UIView *)view;

+(void) addDropShadowToView:(UIView *)view shadowColor:(UIColor *)shadowColor;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+(BOOL) isRTL:(NSString *)string;

+ (void) configurePaidLabelToImageViewIfneeded:(UIImageView *)recImageView withSettings:(OBSettings *)settings;

// Video related methods
+(WKWebView *) createVideoWebViewInsideView:(UIView *)parentView
                                 withSFItem:(SFItemData *)sfItem
                       scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler
                                 uiDelegate:(id <WKUIDelegate>)uiDelegate
                       withHorizontalMargin:(BOOL)withHorizontalMargin;

+(BOOL) configureGenericVideoCell:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem;

+(void) loadRequestIn:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem;

@end
