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
