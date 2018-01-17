//
//  OBDisclosure.m
//  OutbrainSDK
//
//  Created by Oded Regev on 8/2/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import "OBDisclosure.h"
#import "OBContent_Private.h"

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

+ (Class)propertyClassForKey:(NSString *)key
{
    if ([key isEqualToString:@"url"]) return [NSURL class];
    return [super propertyClassForKey:key];
}

#pragma mark - Overrides

+ (id)convertedValue:(id)value withClass:(Class)class
{
    if (class == [NSURL class])
    {
        if ([value isKindOfClass:[NSString class]])
        {
            // this method returns an NSURL object initialized with *value* NSString.
            // If the URL string was malformed or nil, returns nil.
            NSURL *url = [NSURL URLWithString:value];
            if (url != nil) {
                return url;
            }
            else {
                // Returns a representation of the receiver using a given encoding to determine the percent
                // escapes necessary to convert the receiver into a legal URL string.
                NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
                NSString *formattedUrl = [value stringByAddingPercentEncodingWithAllowedCharacters:set];
                return [NSURL URLWithString:formattedUrl];
            }
        }
    }
    
    return value;
}

@end
