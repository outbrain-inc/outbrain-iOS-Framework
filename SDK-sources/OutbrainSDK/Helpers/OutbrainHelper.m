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
#import "OBViewabilityService.h"
#import "OBRecommendation.h"
#import "OBAppleAdIdUtil.h"
#import "OBUtils.h"
#import "GDPRUtils.h"


@interface OBAdChoicesButton : UIButton

@property (copy) OBOnClickBlock block;
@property (nonatomic, copy) NSString *clickUrlString;

@end

@implementation OBAdChoicesButton

@end


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
    
    NSMutableString *requestUrlString = [NSMutableString stringWithString:request.url];
    NSString *base = [NSString stringWithFormat:@"https://odb.outbrain.com/utils/get"];
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
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"idx" value: widgetIdx]];
    
    
    // Request URL - percent encode the urlString
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    NSString *formattedUrl = [requestUrlString stringByAddingPercentEncodingWithAllowedCharacters:set];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"url" value: formattedUrl]];
    
    //Format
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"format" value: @"vjnc"]];
    
    //User key + opt-out
    NSString *apiUserId = [OBAppleAdIdUtil isOptedOut] ? @"null" : [OBAppleAdIdUtil getAdvertiserId];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"api_user_id" value: apiUserId]];
    
    //Test mode
    if ([OutbrainManager sharedInstance].testMode) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"testMode" value: @"true"]];
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"location" value: @"us"]];
        if (request.fid == nil && ![request.widgetId containsString:@"SFD_MAIN"]) {
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"fakeRec" value: @"RTB-CriteoUS"]];
            [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"fakeRecSize" value: @"2"]];
        }
    }
    
    //Installation type
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"installationType" value: @"ios_sdk"]];
    
    // RTB support
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"rtbEnabled" value: @"true"]];
    
    // APP ID \ Bundle ID
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"app_id" value: bundleIdentifier]];
    
    //Is opt out
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"doo" value: ([OBAppleAdIdUtil isOptedOut] ? @"true" : @"false")]];
    
    //OS
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dos" value: @"ios"]];
    
    //OS version
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dosv" value: [[UIDevice currentDevice] systemVersion]]];
    
    //Device model
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dm" value: [OBUtils deviceModel]]];
    
    //Token
    NSString *token = [self.tokensHandler getTokenForRequest:request];
    if (token != nil) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"t" value: token]];
    }
    
    // APV
    if (request.widgetIndex == 0) { // Reset APV on index = 0
        self.apvCache[request.url] = [NSNumber numberWithBool:NO];
    }
    if ([self.apvCache[request.url] boolValue]) {
        // We need to append apv=true to our request
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"apv" value: @"true"]];
    }
    
    // Secure HTTPS
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"secured" value: @"true"]];

    // Smart Feed (father id)
    if (request.fid != nil) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"fid" value: request.fid]];
    }
    
    // GDPR
    if (GDPRUtils.sharedInstance.cmpPresent) {
        // TODO - check if value should be true/false or 1/0/-1
        NSString *subjectToGDPR = GDPRUtils.sharedInstance.subjectToGDPR == SubjectToGDPR_Yes ? @"true" : @"false";
        NSString *consents = GDPRUtils.sharedInstance.consentString;
        NSString *purposes = GDPRUtils.sharedInstance.parsedPurposeConsents;
        BOOL vendorConsentGivenForOutbrain = [GDPRUtils.sharedInstance isVendorConsentGivenFor:164];
        NSString *isOutbarainVendor = vendorConsentGivenForOutbrain ? @"ture" : @"false";

        // TODO - add keys to query params
        // [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"" value: @"true"]];
        // [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"" value: subjectToGDPR]];
        // [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"" value: consents]];
        // [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"" value: purposes]];
        // [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"" value: isOutbarainVendor]];
    } else {
        // [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"" value: @"false"]];
    }
    
    components.queryItems = odbQueryItems;

    return components.URL;
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
    
    // TODO there is some bad code here, we should use OBSettings from "response" all the time.
    // instead, we sometimes use:
    // NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    [self _updateAPVCacheForResponse:response];
    [self _updateViewbilityStatsForResponse:responseSettings];
}

#pragma mark - ODB Settings - Private Methods
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
