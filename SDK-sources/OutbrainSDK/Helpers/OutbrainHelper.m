//
//  OutbrainHelper.m
//  OutbrainSDK
//
//  Created by Oded Regev on 7/6/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OutbrainHelper.h"
#import "OBContent_Private.h"
#import "OutbrainManager.h"
#import "OBDisclosure.h"
#import "OBResponse.h"
#import "OBPlatformRequest.h"
#import "OBViewabilityService.h"
#import "OBRecommendation.h"
#import "OBAppleAdIdUtil.h"
#import "OBUtils.h"
#import "GDPRUtils.h"
#import "SFUtils.h"
#import "OBAppleAdIdUtil.h"

@import StoreKit;

@interface OutbrainHelper()

@property (nonatomic, strong) NSMutableDictionary * apvCache;

@end

@implementation OutbrainHelper

#pragma GCC diagnostic ignored "-Wundeclared-selector"

NSInteger const kAdChoiceButtonTag = 343;
NSString *const kGLOBAL_WIDGET_STATISTICS = @"globalWidgetStatistics";
NSString *const kVIEWABILITY_THRESHOLD = @"ViewabilityThreshold";

+ (OutbrainHelper *) sharedInstance {
    static OutbrainHelper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.apvCache = [[NSMutableDictionary alloc] init];   // Initialize our apv cache.
        sharedInstance.tokensHandler = [[OBRecommendationsTokenHandler alloc] init];
        
    });
    return sharedInstance;
}

#pragma mark - ODB URL Builder

- (NSURL *) recommendationURLForRequest:(OBRequest *)request
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Only need to seed once per app launch
        srand([[NSDate date] timeIntervalSinceNow]);
    });
    
    NSMutableArray *odbQueryItems = [[NSMutableArray alloc] init];
    NSInteger randInteger = (arc4random() % 10000);
    BOOL isPlatfromRequest = [request isKindOfClass:[OBPlatformRequest class]];
    
    NSString *base = [OBAppleAdIdUtil isOptedOut] ? @"https://mv.outbrain.com/Multivac/api/get" : @"https://t-mv.outbrain.com/Multivac/api/get";
    
    if (isPlatfromRequest) {
        base = [OBAppleAdIdUtil isOptedOut] ? @"https://mv.outbrain.com/Multivac/api/platforms" : @"https://t-mv.outbrain.com/Multivac/api/platforms";
    }
    
    NSURLComponents *components = [NSURLComponents componentsWithString: base];
    
    //Key
    NSString *partnerKey = [OutbrainManager sharedInstance].partnerKey;
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"key" value: (partnerKey ? partnerKey : @"(null)")]];
    
    //Version
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"version" value: OB_SDK_VERSION]];
    
    //App Version
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [appVersionString stringByReplacingOccurrencesOfString:@" " withString:@""]; // sanity fix
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"app_ver" value: appVersionString]];
    
    //Random
    NSString *randNumStr = [NSString stringWithFormat:@"%li", (long)randInteger];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"rand" value: randNumStr]];
    
    //WidgetId
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"widgetJSId" value: request.widgetId]];
    
    //Idx
    NSString *widgetIdx = [NSString stringWithFormat:@"%li", (long)request.widgetIndex];
    if (request.isMultivac) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"feedIdx" value:widgetIdx]];
    }
    else {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"idx" value:widgetIdx]];
    }
    
    // Request URL - percent encode the urlString
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *requestUrlString = [OBUtils getRequestUrl:request];
    if (isPlatfromRequest) {
        OBPlatformRequest *req = (OBPlatformRequest *)request;
        NSString *formattedUrl = [requestUrlString stringByAddingPercentEncodingWithAllowedCharacters:set];
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:req.bundleUrl ? @"bundleUrl" : @"portalUrl" value: formattedUrl]];
    }
    else {
        NSString *formattedUrl = [requestUrlString stringByAddingPercentEncodingWithAllowedCharacters:set];
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"url" value: formattedUrl]];
    }
    
    //Format
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"format" value: @"vjnc"]];
    
    //User key + opt-out
    NSString *apiUserId = [OBAppleAdIdUtil isOptedOut] ? @"null" : [OBAppleAdIdUtil getAdvertiserId];
    if ([[OutbrainManager sharedInstance] customUserId]) {
        apiUserId = [[OutbrainManager sharedInstance] customUserId];
    }
    
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"api_user_id" value: apiUserId]];
    
    // OS Tracking
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"ostracking" value: [OBAppleAdIdUtil isOptedOut] ? @"false" : @"true"]];
    
    //Test mode
    if ([OutbrainManager sharedInstance].testMode) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"testMode" value: @"true"]];
        
        // Test RTB recs (only in testMode)
        if ([OutbrainManager sharedInstance].testRTB) {
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"fakeRec" value: @"RTB-CriteoUS"]];
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"fakeRecSize" value: @"2"]];
        }
        // simulate location
        if ([OutbrainManager sharedInstance].testLocation) {
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"location" value: [OutbrainManager sharedInstance].testLocation]];
        }
    }
    
    //Installation type
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"installationType" value: @"ios_sdk"]];
    
    // RTB support
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"rtbEnabled" value: @"true"]];
    
    // sk_network_version
    // if app built with SDK14 - SKStoreProductParameterAdNetworkVersion will be available
    NSString *skNetworkVersion = @"1.0";
    if (@available(iOS 14, *)) {
        skNetworkVersion = @"2.0";
    }
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"sk_network_version" value: skNetworkVersion]];
    
    // APP ID \ Bundle ID
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"app_id" value: bundleIdentifier]];
    
    //Is opt out
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"doo" value: ([OBAppleAdIdUtil isOptedOut] ? @"true" : @"false")]];
    
    //OS
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dos" value: @"ios"]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"platform" value: @"ios"]];
    
    //OS version
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dosv" value: [[UIDevice currentDevice] systemVersion]]];
    
    //Device model
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dm" value: [OBUtils deviceModel]]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"deviceType" value: [OBUtils deviceTypeShort]]];
    
    //Viewability actions
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"va" value: @"true"]];
    
    //Token
    NSString *token = [self.tokensHandler getTokenForRequest:request];
    if (token != nil) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"t" value: token]];
    }
    
    // APV
    BOOL apvValue = [self _getApvForRequest:request];
    if (apvValue) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"apv" value: @"true"]];
    }
    
    // Secure HTTPS
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"secured" value: @"true"]];
    
    // Refferer
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"ref" value: @"https://app-sdk.outbrain.com/"]];
    
    // External ID
    if (request.externalID != nil) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"extid" value: request.externalID]];
    }
    
    // Secondary External ID
    if (request.extSecondaryId != nil) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"extid2" value: request.extSecondaryId]];
    }
    
    // pubImpId param
    if (request.obPubImp != nil) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"pubImpId" value: request.obPubImp]];
    }
    
    // GDPR v1
    NSString *consentString;
    if (GDPRUtils.sharedInstance.cmpPresent) {
        consentString = GDPRUtils.sharedInstance.gdprV1ConsentString;
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"cnsnt" value: consentString]];
    }
    // GDPR v2
    if (GDPRUtils.sharedInstance.gdprV2ConsentString) {
        consentString = GDPRUtils.sharedInstance.gdprV2ConsentString;
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"cnsntv2" value: consentString]];
    }
    // CCPA
    if (GDPRUtils.sharedInstance.ccpaPrivacyString) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"ccpa" value: GDPRUtils.sharedInstance.ccpaPrivacyString]];
    }
    
    // Dark Mode param (Smartfeed only)
    if (request.isSmartfeed) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"darkMode" value: [[SFUtils sharedInstance] darkMode] ? @"true" : @"false"]];
    }
    
    
    // Multivac
    if (request.isMultivac) {
        NSString *lastCardIdx = [NSString stringWithFormat:@"%li", (long)request.lastCardIdx];
        NSString *lastIdx = [NSString stringWithFormat:@"%li", (long)request.widgetIndex];
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"lastCardIdx" value: lastCardIdx]];
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"lastIdx" value: lastIdx]];
        if (request.fab) {
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"fab" value: request.fab]];
        }
    }
    
    // Platforms
    if (isPlatfromRequest) {
        OBPlatformRequest *req = (OBPlatformRequest *)request;
        if (req.lang) {
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"lang" value: req.lang]];
        }
        if (req.psub) {
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"psub" value: req.psub]];
        }
    }
    
    components.queryItems = odbQueryItems;
    NSLog(@"URL: %@", components.URL);
    return components.URL;
}

#pragma mark - ODB Settings
- (void) updateApvCacheAndViewabilitySettings:(OBRecommendationResponse *)response {
    // We only update Settings in the case the response did not error.
    if ([response performSelector:@selector(getPrivateError)]) {
        return;
    }
    OBSettings *responseSettings = response.settings;
    NSDictionary * responseSettingsDict = [response originalValueForKeyPath:@"settings"];
    
    // Sanity
    if (responseSettings == nil || (responseSettingsDict == nil) || ![responseSettingsDict isKindOfClass:[NSDictionary class]]) {
        NSAssert(NO, @"We expect OBSettings to be included in the response as expected");
        return;
    }
    
    // TODO there is some bad code here, we should use OBSettings from "response" all the time.
    // instead, we sometimes use:
    // NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    [self _updateAPVCacheForResponse:response];
    [self _updateViewbilityStatsForResponse:responseSettingsDict];
}

#pragma mark - ODB Settings - Private Methods
- (void)_updateViewbilityStatsForResponse:(NSDictionary *)responseSettingsDict {
    // Update kViewabilityEnabledKey
    [self _updateODBSetting:responseSettingsDict[kGLOBAL_WIDGET_STATISTICS] defaultValue:[NSNumber numberWithBool:YES] saveValueBlock:^(NSNumber *value) {
        [[OBViewabilityService sharedInstance] updateViewabilitySetting:value key:kViewabilityEnabledKey];
    }];
    
    // Update kViewabilityThresholdKey
    [self _updateODBSetting:responseSettingsDict[kVIEWABILITY_THRESHOLD] defaultValue:[NSNumber numberWithInt:1000] saveValueBlock:^(NSNumber *value) {
        [[OBViewabilityService sharedInstance] updateViewabilitySetting:value key:kViewabilityThresholdKey];
    }];
}

#pragma mark - APV logic
- (void) _cleanAPVCache {
    self.apvCache = [[NSMutableDictionary alloc] init];
}

- (NSInteger) _getApvCacheSize {
    return self.apvCache.allKeys.count;
}

- (BOOL) _getApvForRequest:(OBRequest *)request {
    NSString *requestUrlString = [OBUtils getRequestUrl:request];
    if (request.widgetIndex == 0) { // Reset APV on index = 0
        self.apvCache[requestUrlString] = [NSNumber numberWithBool:NO];
    }
    if ([self.apvCache[requestUrlString] boolValue]) {
        return YES;
    }
    return NO;
}

- (void) _updateAPVCacheForResponse:(OBRecommendationResponse *)response
{
    OBSettings *responseSettings = response.settings;
    
    OBRequest *request = [response performSelector:@selector(getPrivateRequest)];
    if (request == nil) return; // sanity

    NSString *requestUrl = [OBUtils getRequestUrl:request];
    
    // If apv = true we don't want to set anything;
    if (self.apvCache[requestUrl] && ([self.apvCache[requestUrl] boolValue] == YES)) {
        return;
    }
    
    // If responseSettings.apv is false we don't want to set anything
    if (responseSettings.apv == NO) return;
    
    // Finally, if we got here, we need to save the apv value to the apvCache
    self.apvCache[requestUrl] = [NSNumber numberWithBool:YES]; 
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

-(NSArray *) advertiserIdURLParams {
  NSMutableArray *params = [[NSMutableArray alloc] init];
  
  //Is opt out
  [params addObject:[NSURLQueryItem queryItemWithName:@"doo" value: ([OBAppleAdIdUtil isOptedOut] ? @"true" : @"false")]];
  
  //User key + opt-out
  NSString *apiUserId = [OBAppleAdIdUtil isOptedOut] ? @"null" : [OBAppleAdIdUtil getAdvertiserId];
  [params addObject:[NSURLQueryItem queryItemWithName:@"advertiser_id" value: apiUserId]];
  return params;
}

@end
