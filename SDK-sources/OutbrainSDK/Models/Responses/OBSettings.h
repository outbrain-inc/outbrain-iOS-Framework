//
//  OBSettingsResponse.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 7/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "Outbrain.h"

@interface OBSettings : NSObject

@property (nonatomic, assign, readonly) BOOL apv;
@property (nonatomic, assign, readonly) BOOL isSmartFeed;
@property (nonatomic, strong, readonly) NSArray *feedContentArray;

- (instancetype)initWithPayload:(NSDictionary *)payload;


@end
