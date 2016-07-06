//
//  OutbrainHelper.m
//  OutbrainSDK
//
//  Created by Oded Regev on 7/6/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OutbrainHelper.h"

#import "Outbrain_Private.h"
#import "OBContent_Private.h"


#import "OBResponse.h"
#import "OBViewabilityService.h"
#import "CustomWebViewManager.h"
#import "OBRecommendation.h"
#import "OBAppleAdIdUtil.h"



#import <sys/utsname.h>


@interface OutbrainHelper()

@property (nonatomic, strong) NSMutableDictionary * apvCache;
@property (nonatomic, strong) NSMutableDictionary *obSettings;       // Settings payload that the sdk is initialized with

@end

@implementation OutbrainHelper

#pragma GCC diagnostic ignored "-Wundeclared-selector"

NSString *const kGLOBAL_WIDGET_STATISTICS = @"globalWidgetStatistics";
NSString *const kVIEWABILITY_THRESHOLD = @"ViewabilityThreshold";

NSString *const kIS_CUSTOM_WEBVIEW_ENABLE = @"cwvReportingEnable";
NSString *const kCWV_THRESHOLD = @"cwvReportingThreshold";
NSString *const kCWV_CONTEXT_FLAG = @"cwvContext=";

+ (OutbrainHelper *) sharedInstance {
    static OutbrainHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.apvCache = [[NSMutableDictionary alloc] init];   // Initialize our apv cache.
        sharedInstance.obSettings = [[NSMutableDictionary alloc] init];
        sharedInstance.tokensHandler = [[OBRecommendationsTokenHandler alloc] init];
        
    });
    return sharedInstance;
}

#pragma mark - ODB URL Builder

#define OBRecommendationDomain                      @"odb.outbrain.com"

- (NSURL *) recommendationURLForRequest:(OBRequest *)request
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Only need to seed once per app launch
        srand([[NSDate date] timeIntervalSinceNow]);
    });
    
    NSInteger randInteger = (arc4random() % 10000);
    
    NSMutableString * urlString = [NSMutableString stringWithString:request.url];
    
    NSString *parameterDelimiter;
    
    NSRange additionDataRange = [urlString rangeOfString:@"additionalData" options:NSCaseInsensitiveSearch];
    NSRange mobileSubGroupRange = [urlString rangeOfString:@"mobileSubGroup" options:NSCaseInsensitiveSearch];
    
    NSRange hashtagRange = [urlString rangeOfString:@"#" options:NSCaseInsensitiveSearch];
    
    if (additionDataRange.length == 0) {
        if (hashtagRange.length == 0) {
            parameterDelimiter = @"#";
        }
        else {
            parameterDelimiter = @"&";
        }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if(request.mobileId && request.mobileId.length > 0) {
            [urlString appendFormat:@"%@additionalData=%@", parameterDelimiter, request.mobileId];
        }
#pragma GCC diagnostic pop
    }
    
    hashtagRange = [urlString rangeOfString:@"#" options:NSCaseInsensitiveSearch];
    
    if (mobileSubGroupRange.length == 0) {
        if (hashtagRange.length == 0) {
            parameterDelimiter = @"#";
        }
        else {
            parameterDelimiter = @"&";
        }
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        if(request.source && request.source.length > 0) {
            [urlString appendFormat:@"%@mobileSubGroup=%@", parameterDelimiter, request.source];
        }
#pragma GCC diagnostic pop
    }
    
    //Domain
    NSString * base = @"http://";
    base = [base stringByAppendingString:OBRecommendationDomain];
    base = [base stringByAppendingString:@"/utils/get"];
    
    //Key
    base = [base stringByAppendingString:[NSString stringWithFormat:@"?key=%@", [self partnerKey]]];
    
    //Version
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&version=%@", OB_SDK_VERSION]];
    
    //App Version
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [appVersionString stringByReplacingOccurrencesOfString:@" " withString:@""]; // sanity fix
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&app_ver=%@", appVersionString]];
    
    //Random
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&rand=%li", (long)randInteger]];
    
    //WidgetId
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&widgetJSId=%@", request.widgetId]];
    
    //Idx
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&idx=%li", (long)request.widgetIndex]];
    
    NSString *encodedUrl = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                                 (CFStringRef) urlString,
                                                                                                 NULL,
                                                                                                 (CFStringRef) @"!*'();:@&=+$,/?%#[]",
                                                                                                 kCFStringEncodingUTF8);
    
    //Url
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&url=%@", encodedUrl]];
    
    //Format
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&format=%@", @"vjnc"]];
    
    //User key + opt-out
    base = [base stringByAppendingString:@"&api_user_id="];
    base = [base stringByAppendingString:([OBAppleAdIdUtil isOptedOut] ? @"null" : [OBAppleAdIdUtil getAdvertiserId])];
    
    //Test mode
    base = [base stringByAppendingString:[((NSNumber *)[[OutbrainHelper sharedInstance] sdkSettingForKey:OBSettingsAttributes.testModeKey]) boolValue] ? @"&testMode=true" : @""];
    
    //Installation type
    base = [base stringByAppendingString:@"&installationType=ios_sdk"];
    
    //Is opt out
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&doo=%@", ([OBAppleAdIdUtil isOptedOut] ? @"true" : @"false")]];
    
    //OS
    base = [base stringByAppendingString:@"&dos=ios"];
    
    //OS version
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&dosv=%@", [[UIDevice currentDevice] systemVersion]]];
    
    //Device model
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&dm=%@", deviceModel]];
    
    //Token
    NSString *token = [self.tokensHandler getTokenForRequest:request];
    
    base = [base stringByAppendingString:(token == nil ? @"" : [NSString stringWithFormat:@"&t=%@", token])];
    
    // APV
    if(request.widgetIndex == 0) { // Reset APV on index = 0
        self.apvCache[request.url] = [NSNumber numberWithBool:NO];
    }
    if ([self.apvCache[request.url] boolValue]) {
        // We need to append apv=true to our request
        base = [base stringByAppendingString:@"&apv=true"];
    }
    
    return [NSURL URLWithString:base];
}

#pragma mark - ODB Settings
- (void) updateODBSettings:(OBResponse *)response {
    // We only update Settings in the case the response did not error.
    if ([response performSelector:@selector(getPrivateError)]) {
        return;
    }
    
    NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    // Sanity
    if ((responseSettings == nil) || ![responseSettings isKindOfClass:[NSDictionary class]]) {
        return;
    }
    
    [self _updateAPVCacheForResponse:response];
    [self _updateViewbilityStatsForResponse:responseSettings];
    [self updateCustomWebViewSettings:responseSettings];
}



#pragma mark - ODB Settings - Private Methods

- (void) updateCustomWebViewSettings:(NSDictionary *)responseSettings {
    
    // Update kCustomWebViewReportingEnabledKey
    [self _updateODBSetting:responseSettings[kIS_CUSTOM_WEBVIEW_ENABLE] defaultValue:[NSNumber numberWithBool:YES] saveValueBlock:^(NSNumber *value) {
        [[CustomWebViewManager sharedManager] updateCWVSetting:value key:kCustomWebViewReportingEnabledKey];
    }];
    
    // Update kCustomWebViewThresholdKey
    [self _updateODBSetting:responseSettings[kCWV_THRESHOLD] defaultValue:[NSNumber numberWithInt:80] saveValueBlock:^(NSNumber *value) {
        [[CustomWebViewManager sharedManager] updateCWVSetting:value key:kCustomWebViewThresholdKey];
    }];
}

- (void)_updateViewbilityStatsForResponse:(NSDictionary *)responseSettings {
    // Update kViewabilityEnabledKey
    [self _updateODBSetting:responseSettings[kGLOBAL_WIDGET_STATISTICS] defaultValue:[NSNumber numberWithBool:YES] saveValueBlock:^(NSNumber *value) {
        [[OBViewabilityService sharedInstance] updateViewabilitySetting:value key:kViewabilityEnabledKey];
    }];
    
    // Update kViewabilityThresholdKey
    [self _updateODBSetting:responseSettings[kVIEWABILITY_THRESHOLD] defaultValue:[NSNumber numberWithInt:1000] saveValueBlock:^(NSNumber *value) {
        [[OBViewabilityService sharedInstance] updateViewabilitySetting:value key:kViewabilityThresholdKey];
    }];
}

- (void)_updateAPVCacheForResponse:(OBResponse *)response
{
    NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    BOOL apvReturnValue = NO;
    
    OBRequest *request = [response performSelector:@selector(getPrivateRequest)];
    if (request == nil) return; // sanity
    
    NSString *requestUrl = request.url;
    
    // If apv = true we don't want to set anything;
    if (self.apvCache[requestUrl] && ([self.apvCache[requestUrl] boolValue] == YES)) {
        return;
    }
    
    if (responseSettings[@"apv"] && ![responseSettings[@"apv"] isKindOfClass:[NSNull class]])
    {
        apvReturnValue = [responseSettings[@"apv"] boolValue];
    }
    
    // If apvReturnValue is false we don't want to set anything
    if (apvReturnValue == NO) return;
    
    // Finally, if we got here, we need to save the apv value to the apvCache
    self.apvCache[requestUrl] = [NSNumber numberWithBool:apvReturnValue]; // apvReturnValue mush be equal to YES;
}

- (void) _updateODBSetting:(NSNumber *)settingValue defaultValue:(NSNumber *)defaultValue saveValueBlock:(void (^)(NSNumber *))saveBlock {
    if (settingValue && ![settingValue isKindOfClass:[NSNull class]])
    {
        saveBlock(settingValue);
    }
    else {
        // We need to make sure that if field doesn’t appear in the odb response - use the default value explicitly (don’t skip with no action).
        // This should fix the potential bug of switching from a non-default value to a default from the server
        saveBlock(defaultValue);
    }
}


#pragma mark - SDK Settings

- (void)setSDKSettingValue:(id)value forKey:(NSString *)key
{
    if(value == nil)
    {
        // Value is nil.  We should delete the key instead
        [self.obSettings removeObjectForKey:key];
        return;
    }
    
    self.obSettings[key] = value;
}

- (id) sdkSettingForKey:(NSString *)key;
{
    return self.obSettings[key];
}

- (NSString *)partnerKey
{
    return [self sdkSettingForKey:OBSettingsAttributes.partnerKey];
}

- (NSString *)userToken
{
    return [self sdkSettingForKey:OBSettingsAttributes.appUserTokenKey];
}

@end
