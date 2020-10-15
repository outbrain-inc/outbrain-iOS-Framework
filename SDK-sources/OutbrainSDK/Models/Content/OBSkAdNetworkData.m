//
//  OBSkAdNetworkData.m
//  OutbrainSDK
//
//  Created by Oded Regev on 06/09/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "OBSkAdNetworkData.h"

@implementation OBSkAdNetworkData

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBSkAdNetworkData * obSkAdNetworkData = [super contentWithPayload:payload];
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    
    if (payload[@"campaign_id"])
    {
        obSkAdNetworkData.campaignId = [f numberFromString: payload[@"campaign_id"]];
    }
    if (payload[@"timestamp"])
    {
        NSNumber *timestampsNumber = [f numberFromString: payload[@"timestamp"]];
        obSkAdNetworkData.timestamp = [timestampsNumber longValue];
    }
    if (payload[@"source_app_id"]) {
        NSNumber *sourceAppIdNumber = [f numberFromString: payload[@"source_app_id"]];
        obSkAdNetworkData.sourceAppId = sourceAppIdNumber;
    }

    return obSkAdNetworkData;
}

+ (NSDictionary *)propertiesMap
{
    return @{
        @"adNetworkId"      :  @"ad_network_id",
        @"iTunesItemId"     :  @"itunes_item_id",
        @"nonce"            :  @"nonce",
        @"skNetworkVersion" :  @"sk_network_version",
        @"signature"        :  @"signature",
    };
}

@end
