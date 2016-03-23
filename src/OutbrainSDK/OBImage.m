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

#pragma mark - Getters & Setters

- (NSURL *)url {
    return url;
}

- (CGFloat)width {
    return width;
}

- (CGFloat)height {
    return height;
}

- (void)setUrl:(NSURL *)aUrl {
    url = aUrl;
}

- (void)setHeight:(CGFloat)aHeight {
    height = aHeight;
}

- (void)setWidth:(CGFloat)aWidth {
    width = aWidth;
}

@end
