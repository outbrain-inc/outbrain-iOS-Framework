//
//  OBContent.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/10/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "OBContent.h"
#import "OBContent_Private.h"


@interface OBContent()

/**
 *  The original payload this content was generated with
 **/
@property (nonatomic, copy) NSDictionary *originalOBPayload;

@end

@implementation OBContent

+ (BOOL)payloadIsValid:(NSDictionary *)payload
{
    BOOL valid = YES;
    for(NSString * requiredKey in [self requiredKeys])
    {
        if(![payload valueForKey:requiredKey]) valid = NO;  // Required value is missing.
        if([[payload valueForKey:requiredKey] isKindOfClass:[NSString class]] && [[payload valueForKey:requiredKey] length] == 0) valid = NO;   // required value length is '0'
        
        if(!valid) return NO;
    }
    return valid;
}

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    // First we'll validate the payload to make sure all the requiredKeys are in the payload
    if(![self payloadIsValid:payload])
    {
        // Payload is invalid here.
        return nil;
    }
    
    
    OBContent *content = [[[self class] alloc] init];
    content.originalOBPayload = payload;
    
    if([self propertiesMap] != nil)
    {
        // Loop through the propertiesMap and map the payload to properties
        [[self propertiesMap] enumerateKeysAndObjectsUsingBlock:^(NSString * propertyKey, NSString * payloadKey, BOOL *stop) {
            if(payload[payloadKey] && [self propertyClassForKey:payloadKey] != NULL)
            {
                // Here we got a dictionary as the value.  So we should convert it to an object
                Class c = [self propertyClassForKey:payloadKey];
                if(c != NULL)
                {
                    id v = nil;
                    if([c isSubclassOfClass:[OBContent class]])
                        v = [c contentWithPayload:payload[payloadKey]];
                    else
                    {
                        v = [self convertedValue:payload[payloadKey] withClass:c];
                    }
                    [content setValue:v forKey:propertyKey];
                }
            }
            else if(payload[payloadKey])
            {
                // Just a straight string or number
                [content setValue:payload[payloadKey] forKey:propertyKey];
            }
        }];
    }
    
    return content;
}


#pragma mark - Overrides

+ (id)convertedValue:(id)value withClass:(Class)class
{
    if(class == [NSDate class])
    {
        // One dateFormatter since these are expensive
        static NSDateFormatter * formatter = nil;
        if(formatter == nil)
        {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        }
        value = [formatter dateFromString:value];
        
        return value;
    }
    else if(class == [NSURL class])
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
                NSCharacterSet *set = [NSCharacterSet URLHostAllowedCharacterSet];
                NSString *formattedUrl = [value stringByAddingPercentEncodingWithAllowedCharacters:set];
                return [NSURL URLWithString:formattedUrl];
            }
        }
    }
    
    return value;
}

+ (NSArray *)requiredKeys
{
    return nil;
}

+ (NSDictionary *)propertiesMap
{
    return nil;
}

+ (Class)propertyClassForKey:(NSString *)key
{
    return NULL;
}


#pragma mark - Methods

- (id)originalValueForKeyPath:(NSString *)keyPath
{
    if(self.originalOBPayload && [self.originalOBPayload valueForKeyPath:keyPath])
    {
        return [self.originalOBPayload valueForKeyPath:keyPath];
    }
    return nil;
}


@end
