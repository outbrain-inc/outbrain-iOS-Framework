//
//  OBResponseRequest.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBResponseRequest.h"

@implementation OBResponseRequest


- (instancetype)initWithPayload:(NSDictionary *)aPayload
{
    if (self = [super init]) {
        self.payload = aPayload;
        self.token = self.payload[@"t"];
    }
    
    return self;
}

- (NSString *)getStringValueForPayloadKey:(NSString *)payloadKey {
    id object = [self.payload objectForKey:payloadKey];
    if (!object) {
        return nil;
    }
    @try {
        return (NSString *)object;
    }
    @catch (NSException *ex) {
    }
    return nil;
}

- (NSNumber *)getNSNumberValueForPayloadKey:(NSString *)payloadKey {
    id object = [self.payload objectForKey:payloadKey];
    if (!object) {
        return nil;
    }
    @try {
        return (NSNumber *)object;
    }
    @catch (NSException *ex) {

    }
    return nil;
}

@end
