//
//  OBDisclosure.m
//  OutbrainSDK
//
//  Created by Oded Regev on 8/2/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import "OBDisclosure.h"

@implementation OBDisclosure

+ (NSArray *)requiredKeys
{
    return @[@"icon", @"url"];
}

+ (NSDictionary *)propertiesMap
{
    return @{
             @"_imageUrl"  :  @"icon",
             @"_clickUrl"  :  @"url"
             };
}

@end
