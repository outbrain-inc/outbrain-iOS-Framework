//
//  OBImageInfo.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/12/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "OBImageInfo.h"
#import "OBContent_Private.h"


@implementation OBImageInfo

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBImageInfo * imageInfo = [super contentWithPayload:payload];
    
    if (payload[@"imageImpressionType"])
    {
        imageInfo.isGif = [payload[@"imageImpressionType"] isEqualToString:@"DOCUMENT_ANIMATED_IMAGE"];
    }

    return imageInfo;
}

+ (NSArray *)requiredKeys
{
    return @[@"url"];
}

+ (NSDictionary *)propertiesMap
{
    return @{
             @"width":  @"width",
             @"height": @"height",
             @"url":    @"url"
             };
}

+ (Class)propertyClassForKey:(NSString *)key
{
    if ([key isEqualToString:@"url"]) {
        return [NSURL class];
    }
    
    return [super propertyClassForKey:key];
}


@end
