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


extern NSString * const OB_VIDEO_PAUSE_NOTIFICATION;


@protocol SFVideoCellType

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, weak) WKWebView *webview;
@property (nonatomic, strong) SFItemData *sfItem;

@end


@protocol SFPrivateEventListener<NSObject>

- (void) recommendationClicked: (id)sender;
- (void) adChoicesClicked:(id)sender;
- (void) outbrainLabelClicked:(id)sender;

// Read more module
- (void) readMoreButtonClicked:(id)sender;

@optional

- (BOOL) isVideoCurrentlyPlaying;

@end

@interface SFUtils : NSObject

@property (nonatomic, assign) BOOL darkMode;

+(SFUtils *) sharedInstance;
-(UIColor *) primaryBackgroundColor;
-(UIColor *) titleColor:(BOOL) isPaid;
-(UIColor *) subtitleColor:(NSString *)abTestSourceFontColor;


+ (BOOL) skipRTL;
+ (void) setSkipRTL:(BOOL)val;

+(void) addConstraintsToFillParent:(UIView *)view;

+(void) addConstraintsToFillParentWithHorizontalMargin:(UIView *)view;

+(void) addDropShadowToView:(UIView *)view;

+(void) addDropShadowToView:(UIView *)view shadowColor:(UIColor *)shadowColor;

+ (UIColor *)colorFromHexString:(NSString *)hexString;

+(BOOL) isRTL:(NSString *)string;

+ (void) removePaidLabelFromImageView:(UIImageView *)recImageView;

+ (void) configurePaidLabelToImageViewIfneeded:(UIImageView *)recImageView withSettings:(OBSettings *)settings;

// Video related methods
+(WKWebView *) createVideoWebViewInsideView:(UIView *)parentView
                                 withSFItem:(SFItemData *)sfItem
                       scriptMessageHandler:(id <WKScriptMessageHandler>)scriptMessageHandler
                                 uiDelegate:(id <WKUIDelegate>)uiDelegate
                       withHorizontalMargin:(BOOL)withHorizontalMargin;

+(BOOL) configureGenericVideoCell:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem;

+(void) loadVideoURLIn:(id<SFVideoCellType>)videoCell sfItem:(SFItemData *)sfItem;

+(BOOL) isVideoIncludedInResponse:(OBRecommendationResponse *)response;

+(NSString *) videoParamsStringFromResponse:(OBRecommendationResponse *)response;

+(NSURL *) appendParamsToVideoUrl:(OBRecommendationResponse *)response url:(NSString *)url;

+(NSString *) getSourceTextForRec:(OBRecommendation *)rec withSettings:(OBSettings *)obSettings;

+(void) setFontSizeForTitleLabel:(UILabel *)titleLabel andSourceLabel:(UILabel *)sourceLabel withAbTestSettings:(OBSettings *)settings;

+ (UILabel *) getRecCtaLabelWithText:(NSString *)ctaText;

@end
