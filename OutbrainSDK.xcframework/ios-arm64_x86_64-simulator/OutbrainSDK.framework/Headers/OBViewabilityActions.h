//
//  OBViewabilityActions.h
//  OutbrainSDK
//
//  Created by Alon Shprung on 3/19/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import "Outbrain.h"

@interface OBViewabilityActions : NSObject

@property (nonatomic, copy, readonly, nullable) NSString *reportServedUrl;
@property (nonatomic, copy, readonly, nullable) NSString *reportViewedUrl;

- (instancetype _Nonnull )initWithPayload:(NSDictionary * _Nullable)payload;

@end
