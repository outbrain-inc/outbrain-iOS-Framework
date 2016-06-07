//
//  OBRecommendation.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendation.h"
#import "OBContent_Private.h"

#define OBPublishDateKey @"OBPublishDateKey"
#define OBSourceURLKey @"OBSourceURLKey"
#define OBAuthorKey @"OBAuthorKey"
#define OBContentKey @"OBContentKey"
#define OBSourceKey @"OBSourceKey"
#define OBSameSourceKey @"OBSameSourceKey"
#define OBPaidLinkKey @"OBPaidLinkKey"
#define OBVideoKey @"OBVideoKey"

@implementation OBRecommendation
@synthesize publishDate;
@synthesize sourceURL;

- (void)encodeWithCoder:(NSCoder *)coder {
   [coder encodeObject:publishDate forKey:OBPublishDateKey];
   [coder encodeObject:sourceURL forKey:OBSourceURLKey];
   [coder encodeObject:author forKey:OBAuthorKey];
   [coder encodeObject:content forKey:OBContentKey];
   [coder encodeObject:source forKey:OBSourceKey];

}
- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        self.publishDate = [coder decodeObjectForKey:OBPublishDateKey];
        self.sourceURL = [coder decodeObjectForKey:OBSourceURLKey];
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
             @"author":@"author",
             @"source":@"source_name",
             @"sourceURL":@"url",
             @"publishDate":@"publish_date",
             @"content":@"content",
             @"sameSource":@"same_source",
             @"image":@"thumbnail",
             @"video":@"isVideo"
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

- (NSURL *)sourceURL {
    return sourceURL;
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

- (void)setSourceURL:(NSURL *)aSourceURL {
    sourceURL = aSourceURL;
}

- (void)setVideo:(BOOL)aVideo {
    video = aVideo;
}

- (NSString *)getPrivateAuthor {
    return author;
}

- (NSString *)getPrivateSource {
    return source;
}

@end
