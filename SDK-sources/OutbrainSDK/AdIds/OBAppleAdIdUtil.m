//
//  OBAppleAdIdUtil.m
//  OutbrainSDK
//
//  Created by Oded Regev on 10/2/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBUtils.h"
#import "OutbrainManager.h"
#import "OBAppleAdIdUtil.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@implementation OBAppleAdIdUtil

+ (BOOL)isOptedOut {
    if (@available(iOS 14, *)) {
        return [ATTrackingManager trackingAuthorizationStatus] != ATTrackingManagerAuthorizationStatusAuthorized;
    }
    else { // for devices with iOS < 14.0
        return ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    }
}

+ (NSString *)getAdvertiserId {
    if ([OutbrainManager sharedInstance].testMode &&
        [[OBUtils deviceModel] isEqualToString:@"Simulator"])
    {
        return @"F22700D5-1D49-42CC-A183-F3676526035F"; // dev hack because simulator returns 0000-0000-0000-0000
    }
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}


@end
