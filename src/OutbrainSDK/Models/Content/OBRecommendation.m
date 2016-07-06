//
//  OBRecommendation.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendation.h"
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
/** @brief should we open this recommendation in an external browser or within the app */
@property (nonatomic, assign, readwrite) BOOL shouldOpenInExternalBrowser;

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

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBRecommendation * recommendation = [super contentWithPayload:payload];
    
    if(payload[@"pc_id"])
    {
        recommendation.paidLink = YES;
    }
    
    NSString *source = [recommendation performSelector:@selector(getPrivateSource)];
    NSString *author = [recommendation performSelector:@selector(getPrivateAuthor)];
    
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
             @"appflow":                            @"appflow"
             };
}

+ (Class)propertyClassForKey:(NSString *)key
{
    if([key isEqualToString:@"thumbnail"]) return [OBImage class];
    if([key isEqualToString:@"publish_date"]) return [NSDate class];
    if([key isEqualToString:@"url"]) return [NSURL class];
    
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
    
    if ([key isEqualToString:@"appflow"]) {
        self.shouldOpenInExternalBrowser = [value[@"shouldOpenInExternalBrowser"] boolValue];
    }
    
    [super setValue:value forKey:key];
}

#pragma mark - Getters & Setters

- (NSDate *)publishDate {
    return publishDate;
}

- (BOOL)isSameSource {
    return sameSource;
}

- (BOOL)isVideo {
    return video;
}

- (OBImage *)image {
    return image;
}

- (NSString *)author {
    return author;
}

- (NSString *)source {
    return source;
}

- (NSURL *)redirectURL {
    return redirectURL;
}

- (NSString *)content {
    return content;
}

- (BOOL)isPaidLink {
    return paidLink;
}

- (void)setSameSource:(BOOL)aSameSource {
    sameSource = aSameSource;
}

- (void)setContent:(NSString *)aContent {
    content = aContent;
}

- (void)setImage:(OBImage *)anImage {
    image = anImage;
}

- (void)setAuthor:(NSString *)anAuthor {
    author = anAuthor;
}

- (void)setPaidLink:(BOOL)aPaidLink {
    paidLink = aPaidLink;
}

- (void)setSource:(NSString *)aSource {
    source = aSource;
}

- (void)setRedirectURL:(NSURL *)aRedirectURL {
    redirectURL = aRedirectURL;
}

- (void)setVideo:(BOOL)aVideo {
    video = aVideo;
}

- (void) setPublishDate:(NSDate *)aPublishDate {
    publishDate = aPublishDate;
}

- (NSString *)getPrivateAuthor {
    return author;
}

- (NSString *)getPrivateSource {
    return source;
}

@end
