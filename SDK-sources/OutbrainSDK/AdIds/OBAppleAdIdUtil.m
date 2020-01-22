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

#define LAST_AD_ID_KEY @"LAST_SAVED_AD_ID"


@implementation OBAppleAdIdUtil

+ (BOOL)isOptedOut {
    return ![[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
}

+ (NSString *)getAdvertiserId {
    if ([OutbrainManager sharedInstance].testMode &&
        [[OBUtils deviceModel] isEqualToString:@"Simulator"])
    {
        return @"F22700D5-1D49-42CC-A183-F3676526035F"; // dev hack because simulator returns 0000-0000-0000-0000
    }
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

+ (BOOL)didUserResetAdvertiserId {
    NSString *lastSavedId = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_AD_ID_KEY];
    NSString *currentId = [self getAdvertiserId];
    
    return ![lastSavedId isEqualToString:currentId];
}

+ (void)refreshAdId {
    [[NSUserDefaults standardUserDefaults] setObject:[self getAdvertiserId] forKey:LAST_AD_ID_KEY];
}

@end
