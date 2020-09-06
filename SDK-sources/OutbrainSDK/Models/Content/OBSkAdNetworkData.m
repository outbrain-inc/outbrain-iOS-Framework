//
//  OBSkAdNetworkData.m
//  OutbrainSDK
//
//  Created by Oded Regev on 06/09/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "OBSkAdNetworkData.h"

@implementation OBSkAdNetworkData

- (instancetype)initWithPayload:(NSDictionary *)payload
{
    if (self = [super init]) {
        
    }
    return self;
}

+ (NSDictionary *)propertiesMap
{
    return @{
        @"adNetworkId"      :  @"ad_network_id",
        @"campaignId"       :  @"campaign_id",
        @"iTunesItemId"     :  @"itunes_item_id",
        @"nonce"            :  @"nonce",
        @"timestamp"        :  @"timestamp",
        @"sourceAppId"      :  @"source_app_id",
        @"skNetworkVersion" :  @"sk_network_version",
        @"signature"        :  @"signature",
    };
}

@end
