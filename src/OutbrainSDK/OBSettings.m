//
//  OBSettingsResponse.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 7/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBSettings.h"

#define NSStringFromBOOL(aBOOL) aBOOL? @"YES" : @"NO"

@implementation OBSettings

- (instancetype)initWithPayload:(NSDictionary *)aPayload
{
    if (self = [super init]) {
        payload = aPayload;
    }
    
    return self;
}

- (NSString *)getStringValueForSettingKey:(NSString *)settingKey {
    id object = [payload objectForKey:settingKey];
    if (!object) {
        //NSLog(@"No object found for setting %@", settingKey);
        return nil;
    }
    @try {
        return (NSString *)object;
    }
    @catch (NSException *ex) {
        //NSLog(@"Error casing setting %@ to NSString", settingKey);
    }
    return nil;
}

- (NSNumber *)getNSNumberValueForSettingKey:(NSString *)settingKey {
    id object = [payload objectForKey:settingKey];
    if (!object) {
        //NSLog(@"No object found for setting %@", settingKey);
        return nil;
    }
    @try {
        return (NSNumber *)object;
    }
    @catch (NSException *ex) {
        //NSLog(@"Error casing setting %@ to NSNumber", settingKey);
    }
    return nil;
}


//
//- (long)provideLongForSetting:(NSString *)setting {
//    NSString *object = [self provideStringForSetting:setting];
//    if (!object) {
//        NSLog(@"No object found for setting %@", setting);
//        return INT_MIN;
//    }
//    @try {
//        long longValue = [object longLongValue];
//        return longValue;
//    }
//    @catch (NSException *ex) {
//        NSLog(@"Error casing setting %@ to long", setting);
//        return INT_MIN;
//    }
//}
//
//- (BOOL)provideBoolForSetting:(NSString *)setting {
//    id object = [payload objectForKey:setting];
//    if (!object) {
//        NSLog(@"No object found for setting %@", setting);
//        return NO;
//    }
//    @try {
//        return (BOOL)object;
//    }
//    @catch (NSException *ex) {
//        NSLog(@"Error casing setting %@ to bool", setting);
//    }
//    return NO;
//}

@end
