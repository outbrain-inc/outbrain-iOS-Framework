//
//  OBResponseRequest.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBResponseRequest : NSObject {
    NSDictionary    *payload;
    NSString        *token;
}

- (instancetype)initWithPayload:(NSDictionary *)aPayload;

@property (nonatomic, copy) NSString        *token;

- (NSString *)getStringValueForPayloadKey:(NSString *)payloadKey;

- (NSNumber *)getNSNumberValueForPayloadKey:(NSString *)payloadKey;

@end
