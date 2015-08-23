//
//  OBResponseRequest.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBResponseRequest.h"

@implementation OBResponseRequest
@synthesize token;

- (instancetype)initWithPayload:(NSDictionary *)aPayload
{
    if (self = [super init]) {
        payload = aPayload;
        self.token = payload[@"t"];
    }
    
    return self;
}

@end