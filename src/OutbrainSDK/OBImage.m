//
//  OBImage.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBImage.h"
#import "OBContent_Private.h"


@implementation OBImage

+ (NSArray *)requiredKeys
{
    return @[@"url"];
}

+ (NSDictionary *)propertiesMap
{
    return @{
             @"width":@"width",
             @"height":@"height",
             @"url":@"url"
             };
}

+ (Class)propertyClassForKey:(NSString *)key
{
    if([key isEqualToString:@"url"]) return [NSURL class];
    return [super propertyClassForKey:key];
}

@end
