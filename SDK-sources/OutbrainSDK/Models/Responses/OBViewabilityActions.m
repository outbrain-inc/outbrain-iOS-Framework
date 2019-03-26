//
//  OBViewabilityActions.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 3/19/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import "OBViewabilityActions.h"

@interface OBViewabilityActions()

@property (nonatomic, copy) NSString *reportServedUrl;
@property (nonatomic, copy) NSString *reportViewedUrl;

@end


@implementation OBViewabilityActions

- (instancetype)initWithPayload:(NSDictionary *)payload
{
    if (self = [super init]) {
        self.reportServedUrl = [payload valueForKey:@"reportServed"];
        self.reportViewedUrl = [payload valueForKey:@"reportViewed"];
    }
    return self;
}

@end

