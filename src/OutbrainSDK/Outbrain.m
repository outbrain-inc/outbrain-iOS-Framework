//
//  OutbrainSDK.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/9/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "Outbrain.h"
#import "Outbrain_Private.h"
#import "OBContent_Private.h"

#import "OBRecommendationRequestOperation.h"
#import "OBClickRegistrationOperation.h"
#import "OBRecommendationResponse.h"
#import "OBResponse.h"
#import "OBRequest.h"

#import "OBAppleAdIdUtil.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"1.6";

BOOL WAS_INITIALISED     =   NO;

// Definitions for our OBSettings attribute keys
const struct OBSettingsAttributes OBSettingsAttributes = {
    
    // `settings` keys
	.partnerKey                 = @"PartnerKey",
    
    // Keychain ids
    .keychainIdentifierKey      = @"com.outbrain.outbrainSDK",
    .keychainServiceUsernameKey = @"OutbrainSDK-Service",
    .keychainServiceNameKey     = @"OutbrainSDKKeychain",
    
    // Misc.
    .udTokenKey                 = @"OB_USER_TOKEN_KEY",
    .apvRequestCacheKey         = @"OB_APV_CAKE_KEY",
    .testModeKey                = @"OB_TEST_MODE_KEY"

};

@implementation Outbrain

#pragma mark - Initialization

+ (void)_throwAssertIfNotInitalized
{
    NSAssert([self partnerKey] != nil, @"Please +initializeOutbrainWithConfigFile: before trying to use outbrain");
}

+ (instancetype)mainBrain
{
    static dispatch_once_t onceToken;
    static Outbrain * instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[Outbrain alloc] init];
        instance.obSettings = [[NSMutableDictionary alloc] init];
        instance.obSettings[OBSettingsAttributes.apvRequestCacheKey] = @{};   // Initialize our apv cache.
        NSOperationQueue * queue = [[NSOperationQueue alloc] init];
        [queue setName:@"Outbrain Operation Queue"];
        queue.maxConcurrentOperationCount = 1;  // Serial
        instance.obRequestQueue = queue;
        instance.tokensHandler = [[OBRecommendationsTokenHandler alloc] init];
        instance.viewabilityService = [[OBViewabilityService alloc] init];
        instance.gaHelper = [[OBGAHelper alloc] init];
        
    });
    
    return instance;
}

+ (void)initializeOutbrainWithConfigFile:(NSString *)pathToFile
{
    if (!WAS_INITIALISED) {

        // First check if it's absolute.  If not then we should try to find it.
        // This way we can pass in `OBConfig.json` or [[NSBundle mainBundle] pathForResource:@"OBConfig" ofType:@"json"];
        if(![pathToFile isAbsolutePath])
        {
            NSArray * fileParts = [pathToFile componentsSeparatedByString:@"."];
            
            pathToFile = [[NSBundle bundleForClass:[self class]] pathForResource:fileParts[0] ofType:(fileParts.count > 1) ? fileParts[1] : @"json"];
        }
     
        NSAssert([[NSFileManager defaultManager] fileExistsAtPath:pathToFile], @"Could not find configuration file at %@.  Please make sure your path is right, and try again",pathToFile);
        
        NSDictionary * settingsPayload = nil;
        
        
        if([[pathToFile pathExtension] isEqualToString:@"plist"])
        {
            // We're loading from a .plist.  We can load directly
            settingsPayload = [NSDictionary dictionaryWithContentsOfFile:pathToFile];
        }
        else
        {
            // Attempt to load as json
            NSData * data = [NSData dataWithContentsOfFile:pathToFile];
            if(data)
            {
                settingsPayload = [NSJSONSerialization JSONObjectWithData:data options:(0) error:nil];
            }
        }
        NSAssert(settingsPayload != nil, @"Could not read file at path.  Please check your file and try again", pathToFile);
        
        // Finally call our dictionary method
        [self initializeOutbrainWithDictionary:settingsPayload];
        [OBGAHelper reportMethodCalled:@"initializeOutbrainWithConfigFile:" withParams:nil];
    }
}

+ (void)initializeOutbrainWithPartnerKey:(NSString *)partnerKey {
    if (!WAS_INITIALISED) {
        // Finally set the settings payload.
        [self initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:partnerKey}];
        [OBGAHelper reportMethodCalled:@"initializeOutbrainWithPartnerKey:" withParams:nil];
    }
}

+ (void)initializeOutbrainWithDictionary:(NSDictionary *)dict
{
    if (!WAS_INITIALISED) {
        NSAssert(dict != nil, @"Invalid payload given for initialization.  Check your parameters and try again");
        
        NSAssert(dict[OBSettingsAttributes.partnerKey] != nil, @"Partner Key Must not be nil");
        NSAssert([dict[OBSettingsAttributes.partnerKey] length] > 0, @"Invalid partner key set");
        
        // Finally set the settings payload.
        [[[self mainBrain] obSettings] addEntriesFromDictionary:dict];
        [OBGAHelper setAppKey:dict[OBSettingsAttributes.partnerKey]];
        [OBGAHelper setAppVersion:OB_SDK_VERSION];
        WAS_INITIALISED = YES;
    }
}

+ (void)setTestMode:(BOOL)testMode {
    [OBGAHelper reportMethodCalled:@"setTestMode:" withParams:(testMode ? @"YES" : @"NO"), nil];
    [[[self mainBrain] obSettings] setValue:[NSNumber numberWithBool:testMode] forKey:OBSettingsAttributes.testModeKey];
}

#pragma mark - Fetching

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withCallback:(OBResponseCompletionHandler)handler
{
    [OBGAHelper reportMethodCalled:@"fetchRecommendationsForRequest:withCallback:" withParams:request.description, nil];

    [self _fetchRecommendationsWithRequest:request andCallback:handler];
}

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withDelegate:(__weak id<OBResponseDelegate>)delegate
{
    [OBGAHelper reportMethodCalled:@"fetchRecommendationsForRequest:withDelegate:" withParams:request.description, nil];

    [self _fetchRecommendationsWithRequest:request andCallback:^(OBRecommendationResponse *response) {
        if(!delegate)
        {
            // Our delegate has disappeared here. 
            return;
        }
        NSError *error = [response performSelector:@selector(getPrivateError)];
        if(error)
        {
            [delegate outbrainResponseDidFail:error];
        }
        else
        {
            [delegate outbrainDidReceiveResponseWithSuccess:response];
        }
    }];
}


#pragma mark - Clicking

+ (NSURL *)getOriginalContentURLAndRegisterClickForRecommendation:(OBRecommendation *)recommendation
{
    [OBGAHelper reportMethodCalled:@"getOriginalContentURLAndRegisterClickForRecommendation:" withParams:nil];
    
    // Should be initialized
    [self _throwAssertIfNotInitalized];
    
    NSURL * originalURL = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"orig_url"]];
    NSURL * urlWithRedirect = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"url"]];
    
    // We don't need a completion block for this one.  We just need to fire off the request and let it do it's thing
    OBClickRegistrationOperation *clickOP = [OBClickRegistrationOperation operationWithURL:urlWithRedirect];
    [[[self mainBrain] obRequestQueue] addOperation:clickOP];
    return originalURL;
}

#pragma mark - Viewability

//+ (void)reportViewedRecommendation:(OBRecommendation *)recommendation {
//    [OBGAHelper reportMethodCalled:@"reportViewedRecommendation:" withParams:nil];
//
//    [((Outbrain *)[self mainBrain]).viewabilityService addRecommendationToViewedRecommendationsList:recommendation];
//}

+ (void)trackSDKUsage:(BOOL)shouldTrackSDKUsage {
    [OBGAHelper reportMethodCalled:@"setShouldTrackSDKUsage:" withParams:(shouldTrackSDKUsage ? @"YES" : @"NO"), nil];
    [OBGAHelper setShouldReportSDKUsage:shouldTrackSDKUsage];
}

@end






/**
 *  Keeping these down here so they're out of the way.
 **/


/**
 *  These are methods that are now and will forever be internal
 **/
@implementation Outbrain (InternalMethods)


#pragma mark - General

+ (void)_fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler {
    [self _throwAssertIfNotInitalized];
    // This is where the magic happens
    // Let's first validate any parameters that we can.
    // AKA sanity checks
    BOOL (^CheckParamAndReturnIfInvalid)(NSString *value) = ^(NSString *value) {
        BOOL valid = (value != nil && [value length] > 0);
        
        if(!valid)
        {
            // If parameter `value` is not valid then create a response with an error and return here
            OBRecommendationResponse * response = [[OBRecommendationResponse alloc] init];
            response.error = [NSError errorWithDomain:OBNativeErrorDomain code:OBInvalidParametersErrorCode userInfo:nil];
            if(handler)
            {
                handler(response);
            }
        }
        
        return valid;
    };
    
    if(!CheckParamAndReturnIfInvalid(request.url)) return;
    if(!CheckParamAndReturnIfInvalid(request.widgetId)) return;
    
    OBRecommendationRequestOperation *recommendationOperation = [OBRecommendationRequestOperation operationWithURL:[self _recommendationURLForRequest:request]];
    recommendationOperation.request = request;
    
    // No retain cycles here
    typeof(recommendationOperation) __strong __recommendationOperation = recommendationOperation;
    typeof(self) __weak __self = self;
    
    [recommendationOperation setCompletionBlock:^{
        typeof(__recommendationOperation) __strong _recommendationOperation = __recommendationOperation;
        
        // Here we need to update our apvCache.
        OBRecommendationResponse * response = _recommendationOperation.response;
        [__self _updateAPVCacheForResponse:response];
        response.recommendations = [__self _filterInvalidRecsForResponse:response];
        [((Outbrain *)[self mainBrain]).tokensHandler setTokenForRequest:request response:response];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(handler)
            {
                handler(response);
            }
        });
    }];
    
    [[[self mainBrain] obRequestQueue] addOperation:recommendationOperation];
}

+ (NSArray *)_filterInvalidRecsForResponse:(OBRecommendationResponse *)response {
    NSMutableArray *filteredResponse = [[NSMutableArray alloc] init];
    for (OBRecommendation *rec in response.recommendations) {
        NSString *stringUrl = [rec performSelector:@selector(originalValueForKeyPath:) withObject:@"orig_url"];
        NSURL *url = [NSURL URLWithString:stringUrl];
        if (url) {
            [filteredResponse addObject:rec];
        }
        else {
            stringUrl = [stringUrl stringByAddingPercentEscapesUsingEncoding:NSStringEncodingConversionAllowLossy];
            [OBGAHelper reportMethodCalled:@"filteredRecommendation" withConcreteParams:stringUrl shouldForceSend:YES];
        }
    }
    return filteredResponse;
}

+ (void)_updateAPVCacheForResponse:(OBResponse *)response
{
    NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    BOOL apvReturnValue = NO;
    // We only update our apv value in the case that the response did not error.
    if(![response performSelector:@selector(getPrivateError)])
    {
        if(responseSettings && [responseSettings isKindOfClass:[NSDictionary class]] && responseSettings[@"apv"] && ![responseSettings[@"apv"] isKindOfClass:[NSNull class]])
        {
            apvReturnValue = [responseSettings[@"apv"] boolValue];
        }
    }
    
    id settingsResponse = [self OBSettingForKey:OBSettingsAttributes.apvRequestCacheKey];
    if (settingsResponse && ![settingsResponse isKindOfClass:[NSNull class]]) {
        settingsResponse = [NSDictionary dictionary];
    }
    
    NSMutableDictionary * apvCache = [[NSMutableDictionary alloc] initWithDictionary:settingsResponse];
    
    OBRequest *request = [response performSelector:@selector(getPrivateRequest)];
    
    if (response != nil && request != nil && request.widgetId != nil) {
        apvCache[request.widgetId] = @(apvReturnValue);
    }
    [self setOBSettingValue:apvCache forKey:OBSettingsAttributes.apvRequestCacheKey];
}

#define OBHomepageDomain                            @"hpr.outbrain.com"
#define OBRecommendationDomain                      @"odb.outbrain.com"

+ (NSURL *)_recommendationURLForRequest:(OBRequest *)request
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
        
        if(request.additionalData && request.additionalData.length > 0) {
            [urlString appendFormat:@"%@additionalData=%@", parameterDelimiter, request.additionalData];
        }
    }
    
    hashtagRange = [urlString rangeOfString:@"#" options:NSCaseInsensitiveSearch];

    if (mobileSubGroupRange.length == 0) {
        if (hashtagRange.length == 0) {
            parameterDelimiter = @"#";
        }
        else {
            parameterDelimiter = @"&";
        }
        
        if(request.mobileSubGroup && request.mobileSubGroup.length > 0) {
            [urlString appendFormat:@"%@mobileSubGroup=%@", parameterDelimiter, request.mobileSubGroup];
        }
    }
    
    //Domain
    NSString * base = @"http://";
    NSString * domain = [request isHomepageRequest] ? OBHomepageDomain : OBRecommendationDomain;
    base = [base stringByAppendingString:domain];
    base = [base stringByAppendingString:@"/utils/get"];
    
    //Key
    base = [base stringByAppendingString:[NSString stringWithFormat:@"?key=%@", [self partnerKey]]];
    
    //Version
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&version=%@", OB_SDK_VERSION]];
    
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
    base = [base stringByAppendingString:([OBAppleAdIdUtil isOptedOut] ? @"" : [NSString stringWithFormat:@"&api_user_id=%@", [OBAppleAdIdUtil getAdvertiserId]])];
    
    //Test mode
    base = [base stringByAppendingString:[((NSNumber *)[Outbrain mainBrain].obSettings[OBSettingsAttributes.testModeKey]) boolValue] ? @"&testMode=true" : @""];
    
    //Installation type
    base = [base stringByAppendingString:[((NSNumber *)[Outbrain mainBrain].obSettings[OBSettingsAttributes.testModeKey]) boolValue] ? @"&installationType=ios_sdk" : @""];
    
    //Is opt out
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&doo=%@", ([OBAppleAdIdUtil isOptedOut] ? @"true" : @"false")]];
    
    //OS
    base = [base stringByAppendingString:@"&dos=ios"];

    //OS version
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&dosv=%.3f", [[[UIDevice currentDevice] systemVersion] floatValue]]];
    
    //Device model
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&dm=%@", deviceModel]];

    //Token
    NSString *token = [((Outbrain *)[self mainBrain]).tokensHandler getTokenForRequest:request];
    base = [base stringByAppendingString:(token == nil ? @"" : [NSString stringWithFormat:@"&t=%@", token])];
    
    // APV
    NSMutableDictionary * apvCache = [[NSMutableDictionary alloc] initWithDictionary:[self OBSettingForKey:OBSettingsAttributes.apvRequestCacheKey]];
    if(request.widgetIndex == 0) apvCache[request.widgetId] = @NO;
    if([apvCache[request.widgetId] boolValue])
    {
        // We need to append apv=true to our request
        base = [base stringByAppendingString:@"&apv=true"];
    }
    
    return [NSURL URLWithString:base];
}


#pragma mark - Settings

+ (void)setOBSettingValue:(id)value forKey:(NSString *)key
{
    if(value == nil)
    {
        // Value is nil.  We should delete the key instead
        [[[self mainBrain] obSettings] removeObjectForKey:key];
        return;
    }
    [[self mainBrain] obSettings][key] = value;
}

+ (id)OBSettingForKey:(NSString *)key
{
    return [[self mainBrain] obSettings][key];
}

@end






/**
 *  Some helpful getters
 **/
@implementation Outbrain (ConvenienceGetters)

+ (NSString *)partnerKey
{
    return [self OBSettingForKey:OBSettingsAttributes.partnerKey];
}

+ (NSString *)userToken
{
    return [self OBSettingForKey:OBSettingsAttributes.appUserTokenKey];
}

@end