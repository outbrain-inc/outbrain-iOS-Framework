//
//  OBRecommendation.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/12/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "OBRecommendation.h"
#import "OBDisclosure.h"
#import "OBContent_Private.h"



@interface OBRecommendation()

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
@property (nonatomic, strong) OBImage *image;
/** @brief An image related to the recommendation. */
@property (nonatomic, strong) OBImage *publisherLogoImage;
/** @brief The appflow settings for the content, currently only shouldOpenInExternalBrowser is supported. */
@property (nonatomic, strong) NSDictionary *appflow;
/** @brief Disclosure icon for conversion campaigns */
@property (nonatomic, strong) OBDisclosure *disclosure;
/** @brief Pixels array for a recommendation to be fired when recommendation received from the server */
@property (nonatomic, strong) NSArray *pixels;
/** @brief The audience campaigns label - null if not audience campaigns. */
@property (nonatomic, copy) NSString *audienceCampaignsLabel;

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
    
    if(payload[@"pc_id"])
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
    
    return recommendation;
}


+ (NSDictionary *)propertiesMap
{
    return @{
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
             @"pixels":                             @"pixels"
             };
}

+ (Class)propertyClassForKey:(NSString *)key
{
    if ([key isEqualToString:@"thumbnail"])         return [OBImage class];
    if ([key isEqualToString:@"logo"])              return [OBImage class];
    if ([key isEqualToString:@"disclosure"])        return [OBDisclosure class];
    if ([key isEqualToString:@"publish_date"])      return [NSDate class];
    if ([key isEqualToString:@"url"])               return [NSURL class];
    
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
    
    [super setValue:value forKey:key];
}


@end
