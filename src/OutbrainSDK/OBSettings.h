//
//  OBSettingsResponse.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 7/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <OutbrainSDK/OutbrainSDK.h>

@interface OBSettings : NSObject {
    NSDictionary *payload;
}

- (instancetype)initWithPayload:(NSDictionary *)aPayload;

- (NSString *)getStringValueForSettingKey:(NSString *)settingKey;

- (NSNumber *)getNSNumberValueForSettingKey:(NSString *)settingKey;

//- (NSString *)provideStringForSetting:(NSString *)setting;
//- (long)provideLongForSetting:(NSString *)setting;
//- (BOOL)provideBoolForSetting:(NSString *)setting;

@end