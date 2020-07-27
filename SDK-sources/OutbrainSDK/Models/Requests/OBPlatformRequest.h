//
//  OBPlatformRequest.h
//  OutbrainSDK
//
//  Created by oded regev on 27/07/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <OutbrainSDK/OutbrainSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface OBPlatformRequest : OBRequest

/**
 *  @brief The Bundle URL for the app that displays this widget - for platforms.
 **/
@property (nonatomic, copy) NSString * _Nullable bundleUrl;

/**
 *  @brief The Portal URL for the app that displays this widget - for platforms.
 **/
@property (nonatomic, copy) NSString * _Nullable portalUrl;

/**
 *  @brief Additional source breakdown available for platforms.
 **/
@property (nonatomic, copy) NSString * _Nullable psub;

/**
 *  @brief For language breakdown of the sources
 **/
@property (nonatomic, copy) NSString * _Nonnull lang;

/**
 *  @brief A constructor for defining an OBRequest object.
 *
 *  @param bundleUrl - The Bundle URL for the app that displays this widget - for platforms.
 *  @param lang - For language breakdown of the sources
 *  @param widgetId - a string ID (assigned by your account manager) for the widget in which content recommendations will be displayed.
 *
 *  @note: If you have more than one widgetID on the same page, use widgetIndex to set the corresponding index on the page.
 **/
+ (instancetype _Nonnull)requestWithBundleURL:(NSString * _Nonnull)bundleUrl lang:(NSString * _Nonnull)lang widgetID:(NSString * _Nonnull)widgetId;

@end

NS_ASSUME_NONNULL_END
