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


#define OBPublishDateKey        @"OBPublishDateKey"
#define OBRedirectURLKey        @"OBRedirectURLKey"
#define OBAuthorKey             @"OBAuthorKey"
#define OBContentKey            @"OBContentKey"
#define OBSourceKey             @"OBSourceKey"



@interface OBRecommendation()

/** @brief The date the content was published. */
@property (nonatomic, strong, readwrite) NSDate * publishDate;
/** @brief The re-direct URL of the content. */
@property (nonatomic, strong, readwrite) NSURL * redirectURL;
/** @brief TBD - property may be removed. */
@property (nonatomic, copy, readwrite) NSString * author;
/** @brief The recommendation's title. */
@property (nonatomic, copy, readwrite) NSString * content;
/** @brief The name of the recommendation's source. */
@property (nonatomic, copy, readwrite) NSString * source;
/** @brief Is the recommendation from the same source as the one the user is currently viewing. */
@property (nonatomic, assign, getter = isSameSource, readwrite) BOOL sameSource;
/** @brief Is this a recommendation for which the publisher pays, when your user clicks on it. */
@property (nonatomic, assign, getter = isPaidLink, readwrite) BOOL paidLink;
/** @brief Is the recommendation a link to a video clip. */
@property (nonatomic, assign, getter = isVideo, readwrite) BOOL video;
/** @brief An image related to the recommendation. */
@property (nonatomic, strong, readwrite) OBImage *image;
/** @brief The appflow settings for the content, currently only shouldOpenInExternalBrowser is supported. */
@property (nonatomic, strong, readwrite) NSDictionary *appflow;
/** @brief Disclosure icon for conversion campaigns */
@property (nonatomic, strong, readwrite) OBDisclosure *disclosure;
/** @brief Pixels array for a recommendation to be fired when recommendation received from the server */
@property (nonatomic, strong, readwrite) NSArray *pixels;

@end


@implementation OBRecommendation


- (void)encodeWithCoder:(NSCoder *)coder {
   [coder encodeObject:self.publishDate forKey:OBPublishDateKey];
   [coder encodeObject:self.redirectURL forKey:OBRedirectURLKey];
   [coder encodeObject:self.author forKey:OBAuthorKey];
   [coder encodeObject:self.content forKey:OBContentKey];
   [coder encodeObject:self.source forKey:OBSourceKey];
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.publishDate = [coder decodeObjectForKey:OBPublishDateKey];
        self.redirectURL = [coder decodeObjectForKey:OBRedirectURLKey];
        self.author = [coder decodeObjectForKey:OBAuthorKey];
        self.content = [coder decodeObjectForKey:OBContentKey];
        self.source = [coder decodeObjectForKey:OBSourceKey];
    }
    return self;
}

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
    
    if(source && source.length == 0) recommendation.source = nil;
    if(author && author.length == 0) recommendation.author = nil;
    
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
             @"video":                              @"isVideo",
             @"appflow":                            @"appflow",
             @"disclosure":                         @"disclosure",
             @"pixels":                             @"pixels"
             };
}

+ (Class)propertyClassForKey:(NSString *)key
{
    if ([key isEqualToString:@"thumbnail"])         return [OBImage class];
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
