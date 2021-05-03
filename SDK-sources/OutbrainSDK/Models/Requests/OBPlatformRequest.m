//
//  OBPlatformRequest.m
//  OutbrainSDK
//
//  Created by oded regev on 27/07/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "OBPlatformRequest.h"

@implementation OBPlatformRequest

/**
 *  @brief A constructor for defining an OBRequest object.
 *
 *  @param bundleUrl - The Bundle URL for the app that displays this widget - for platforms.
 *  @param lang - For language breakdown of the sources
 *  @param widgetId - a string ID (assigned by your account manager) for the widget in which content recommendations will be displayed.
 *
 *  @note: If you have more than one widgetID on the same page, use widgetIndex to set the corresponding index on the page.
 **/
+ (instancetype _Nonnull)requestWithBundleURL:(NSString * _Nonnull)bundleUrl lang:(NSString * _Nonnull)lang widgetID:(NSString * _Nonnull)widgetId
{
    NSAssert((widgetId != nil) && (widgetId.length > 0), @"WidgetID must not be empty.");
    NSAssert((bundleUrl != nil) && (bundleUrl.length > 0), @"bundleUrl must not be empty.");
    NSAssert((lang != nil) && (lang.length > 0), @"lang must not be empty.");
    
    OBPlatformRequest * request = [[[self class] alloc] init];
    request.bundleUrl = bundleUrl;
    request.lang = lang;
    request.widgetId = widgetId;
    request.widgetIndex = 0;
    
    return request;
}

/**
 *  @brief A constructor for defining an OBRequest object.
 *
 *  @param portalUrl - for platforms -  instead of URL of the of the page this will include the source representation logic or a page representing the activity
 *  @param lang - For language breakdown of the sources
 *  @param widgetId - a string ID (assigned by your account manager) for the widget in which content recommendations will be displayed.
 *
 *  @note: If you have more than one widgetID on the same page, use widgetIndex to set the corresponding index on the page.
 **/
+ (instancetype _Nonnull)requestWithPortalURL:(NSString * _Nonnull)portalUrl lang:(NSString * _Nonnull)lang widgetID:(NSString * _Nonnull)widgetId {
    NSAssert((widgetId != nil) && (widgetId.length > 0), @"WidgetID must not be empty.");
    NSAssert((portalUrl != nil) && (portalUrl.length > 0), @"portalUrl must not be empty.");
    NSAssert((lang != nil) && (lang.length > 0), @"lang must not be empty.");
    
    OBPlatformRequest * request = [[[self class] alloc] init];
    request.portalUrl = portalUrl;
    request.lang = lang;
    request.widgetId = widgetId;
    request.widgetIndex = 0;
    
    return request;
}

+ (instancetype)requestWithURL:(NSString *)link widgetID:(NSString *)widgetID
{
    NSAssert(NO, @"requestWithURL should not be used by OBPlatformRequest");
    return nil;
}

+ (instancetype)requestWithURL:(NSString *)link widgetID:(NSString *)widgetID widgetIndex:(NSInteger)widgetIndex
{
    NSAssert(NO, @"requestWithURL should not be used by OBPlatformRequest");
    return nil;
}


@end
