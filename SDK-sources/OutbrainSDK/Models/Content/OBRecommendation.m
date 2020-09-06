//
//  OBRecommendation.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/12/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "OBRecommendation.h"
#import "OBDisclosure.h"
#import "OBSkAdNetworkData.h"
#import "OBContent_Private.h"
#import "OBUtils.h"
#import "OutbrainManager.h"

@interface OBRecommendation()

/** @brief The position of the recommendation. */
@property (nonatomic, copy) NSString * position;
/** @brief The date the content was published. */
@property (nonatomic, strong) NSDate * publishDate;
/** @brief The re-direct URL of the content. */
@property (nonatomic, strong) NSURL * redirectURL;
/** @brief TBD - property may be removed. */
@property (nonatomic, copy) NSString * author;
/** @brief The recommendation's title. */
@property (nonatomic, copy) NSString * content;
/** @brief The name of the recommendation's source. */
@property (nonatomic, copy) NSString * source;
/** @brief Is the recommendation from the same source as the one the user is currently viewing. */
@property (nonatomic, assign, getter = isSameSource) BOOL sameSource;
/** @brief Is this a recommendation for which the publisher pays, when your user clicks on it. */
@property (nonatomic, assign, getter = isPaidLink) BOOL paidLink;
/** @brief Is the recommendation a link to a video clip. */
@property (nonatomic, assign, getter = isVideo) BOOL video;
/** @brief An image related to the recommendation. */
@property (nonatomic, strong) OBImageInfo *image;
/** @brief An image related to the recommendation. */
@property (nonatomic, strong) OBImageInfo *publisherLogoImage;
/** @brief The appflow settings for the content, currently only shouldOpenInExternalBrowser is supported. */
@property (nonatomic, strong) NSDictionary *appflow;
/** @brief Disclosure icon for conversion campaigns */
@property (nonatomic, strong) OBDisclosure *disclosure;
/** @brief Pixels array for a recommendation to be fired when recommendation received from the server */
@property (nonatomic, strong) NSArray *pixels;
/** @brief The audience campaigns label - null if not audience campaigns. */
@property (nonatomic, copy) NSString *audienceCampaignsLabel;
/** @brief Apply for Smartfeed "trending in category" card only. */
@property (nonatomic, copy) NSString * categoryName;
/** @brief Apply for Smartfeed "branded carousel" rec only. */
@property (nonatomic, copy) NSString * brandedCardCtaText;
/** @brief metadata for app install ads according to the new iOS14 SkAdNetwork spec. */
@property (nonatomic, strong) OBSkAdNetworkData *skAdNetworkData;

//TODO remove the props below:

/** @brief Is the recommendation an "app install" ad */
@property (nonatomic, assign, getter = isAppInstall) BOOL appInstall;
/** @brief for app install rec - this is the advertiding app itunes identifier (app store id) */
@property (nonatomic, copy) NSString * appInstallItunesItemIdentifier;
@end


@implementation OBRecommendation


-(BOOL) isRTB {
    return [self shouldDisplayDisclosureIcon];
}

-(BOOL) shouldDisplayDisclosureIcon {
    // Check if both disclosure image and click_url exists
    return self.disclosure && self.disclosure.imageUrl && [self.disclosure.imageUrl length] > 0 && self.disclosure.clickUrl && [self.disclosure.clickUrl.absoluteString length] > 0;
}

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBRecommendation * recommendation = [super contentWithPayload:payload];
    
    if (payload[@"pc_id"])
    {
        recommendation.paidLink = YES;
    }
    
    NSString *source = recommendation.source;
    NSString *author = recommendation.author;
    
    if (source && source.length == 0) {
        recommendation.source = nil;
    }
    
    if (author && author.length == 0) {
        recommendation.author = nil;
    }
    
    if (payload[@"publisherAds"] && [payload[@"publisherAds"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = payload[@"publisherAds"];
        if ([dict[@"isPublisherAds"] boolValue]) {
            recommendation.audienceCampaignsLabel = dict[@"label"];
        }
    }
    
    if (payload[@"card"] && [payload[@"card"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = payload[@"card"];
        if (dict[@"contextual_topic"]) {
            recommendation.categoryName = dict[@"contextual_topic"];
        }
    }
    
    BOOL iosVerValidForLoadProduct = YES;
    if (@available(iOS 11.3, *)) {
        iosVerValidForLoadProduct = YES;
    }
    else {
        iosVerValidForLoadProduct = NO;
    }
    
    if ((iosVerValidForLoadProduct == NO) && payload[@"sk_adnetwork_data"]) {
        // skAdNetworkData is relevant only if the device iOS version is >= 11.3 (see https://developer.apple.com/documentation/storekit/skadnetwork)
        recommendation.skAdNetworkData = nil;
    }
    
    if (YES) { //TODO - remove this code - just for simulation
        BOOL appContentIsAppInstall = [recommendation.content containsString:@"Yahtzee lovers"] || [recommendation.content containsString:@"Forge of Empires"] || [recommendation.content containsString:@"Duolingo"];
        
        if (iosVerValidForLoadProduct && appContentIsAppInstall) {
            recommendation.appInstall = YES;
            recommendation.appInstallItunesItemIdentifier = @"711455226";
        }
    }

    return recommendation;
}


+ (NSDictionary *)propertiesMap
{
    return @{
             @"position":                           @"pos",
             @"author":                             @"author",
             @"source":                             @"source_name",
             @"redirectURL":                        @"url",
             @"publishDate":                        @"publish_date",
             @"content":                            @"content",
             @"sameSource":                         @"same_source",
             @"image":                              @"thumbnail",
             @"publisherLogoImage":                 @"logo",
             @"video":                              @"isVideo",
             @"appflow":                            @"appflow",
             @"disclosure":                         @"disclosure",
             @"pixels":                             @"pixels",
             @"brandedCardCtaText":                 @"cta",
             @"skAdNetworkData":                    @"sk_adnetwork_data"
             };
}

+ (Class)propertyClassForKey:(NSString *)key
{
    if ([key isEqualToString:@"thumbnail"])             return [OBImageInfo class];
    if ([key isEqualToString:@"logo"])                  return [OBImageInfo class];
    if ([key isEqualToString:@"disclosure"])            return [OBDisclosure class];
    if ([key isEqualToString:@"publish_date"])          return [NSDate class];
    if ([key isEqualToString:@"url"])                   return [NSURL class];
    if ([key isEqualToString:@"sk_adnetwork_data"])     return [OBSkAdNetworkData class];
    
    return [super propertyClassForKey:key];
}


#pragma mark - Setters

- (void)setValue:(id)value forKey:(NSString *)key
{
    if([key isEqualToString:@"sameSource"] || [key isEqualToString:@"video"])
    {
        if(![value isKindOfClass:[NSValue class]])
        {
            value = @([value boolValue]);
        }
    }
    
    if ([key isEqualToString:@"pixels"]) {
        self.pixels = value;
    }
    
    if ([key isEqualToString:@"content"] && [value isKindOfClass:[NSString class]]) {
        self.content = [OBUtils decodeHTMLEnocdedString:value];;
        return;
    }
    
    [super setValue:value forKey:key];
}

- (NSString *)description {
    return [NSString stringWithFormat: @"%@ - %@", self.content, self.source];
}

@end
