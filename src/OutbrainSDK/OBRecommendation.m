//
//  OBRecommendation.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendation.h"
#import "OBContent_Private.h"


@implementation OBRecommendation

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBRecommendation * recommendation = [super contentWithPayload:payload];
    
    if(payload[@"pc_id"])
    {
        recommendation.paidLink = YES;
    }
    
    if(recommendation.source && recommendation.source.length == 0) recommendation.source = nil;
    if(recommendation.author && recommendation.author.length == 0) recommendation.author = nil;
    
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

@end
