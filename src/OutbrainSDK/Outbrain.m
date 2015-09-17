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
#import "OBKeychainStore.h"
#import "OBResponse.h"
#import "OBRequest.h"

#import "OBAppleAdIdUtil.h"


// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"1.5";

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
        [OBKeychainStore setDefaultService:OBSettingsAttributes.keychainIdentifierKey];
        instance.settings = [[NSMutableDictionary alloc] init];
        instance.settings[OBSettingsAttributes.apvRequestCacheKey] = @{};   // Initialize our apv cache.
        NSOperationQueue * queue = [[NSOperationQueue alloc] init];
        [queue setName:@"Outbrain Operation Queue"];
        queue.maxConcurrentOperationCount = 1;  // Serial
        instance.obRequestQueue = queue;
    });
    return instance;
}

+ (void)initializeOutbrainWithConfigFile:(NSString *)pathToFile
{
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
}

+ (void)initializeOutbrainWithDictionary:(NSDictionary *)dict
{
    NSAssert(dict != nil, @"Invalid payload given for initialization.  Check your parameters and try again");
    
    NSAssert(dict[OBSettingsAttributes.partnerKey] != nil, @"Partner Key Must not be nil");
    NSAssert([dict[OBSettingsAttributes.partnerKey] length] > 0, @"Invalid partner key set");
    
    // Finally set the settings payload.
    [[[self mainBrain] settings] addEntriesFromDictionary:dict];
}

+ (void)setTestMode:(BOOL)testMode {
    [[[self mainBrain] settings] setValue:[NSNumber numberWithBool:testMode] forKey:OBSettingsAttributes.testModeKey];
}

#pragma mark - Fetching

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withCallback:(OBResponseCompletionHandler)handler
{
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
        dispatch_async(dispatch_get_main_queue(), ^{
            if(handler)
            {
                handler(response);
            }
        });
    }];
    
    [[[self mainBrain] obRequestQueue] addOperation:recommendationOperation];
}

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withDelegate:(__weak id<OBResponseDelegate>)delegate
{
    [self fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        if(!delegate)
        {
            // Our delegate has disappeared here. 
            return;
        }
        if(response.error)
        {
            [delegate outbrainResponseDidFail:response.error];
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
    // Should be initialized
    [self _throwAssertIfNotInitalized];
    
    NSURL * originalURL = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"orig_url"]];
    NSURL * urlWithRedirect = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"url"]];
    
    // We don't need a completion block for this one.  We just need to fire off the request and let it do it's thing
    OBClickRegistrationOperation *clickOP = [OBClickRegistrationOperation operationWithURL:urlWithRedirect];
    [[[self mainBrain] obRequestQueue] addOperation:clickOP];
    return originalURL;
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

+ (void)_updateAPVCacheForResponse:(OBResponse *)response
{
    NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    BOOL apvReturnValue = NO;
    // We only update our apv value in the case that the response did not error.
    if(!response.error)
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
    if (response != nil && response.request != nil && response.request.widgetId != nil) {
        apvCache[response.request.widgetId] = @(apvReturnValue);
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
    
    NSString * domain = [request isHomepageRequest] ? OBHomepageDomain : OBRecommendationDomain;
    NSInteger randInteger = (arc4random() % 10000);
    
    // Format:  Domain, PartnerKey, Version, Rand, UserToken, WidgetID, WidgetIndex, URL
    // Url: {url}/?mobileId#clonedSource
    
    NSURL * url = [NSURL URLWithString:request.url];
    NSMutableString * urlString = [NSMutableString stringWithString:request.url];
    
    NSString * appendType = (url.query && url.query.length > 0) ? @"&" : @"?";
    
    if(request.mobileId && request.mobileId.length > 0)
    {
        [urlString appendFormat:@"%@mobileId=%@", appendType, request.mobileId];
    }
    if(request.source && request.source.length > 0)
    {
        [urlString appendFormat:@"#clonedSource=%@",request.source];
    }
    NSString * base = @"http://";
    base = [base stringByAppendingString:domain];
    base = [base stringByAppendingString:@"/utils/get"];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"?key=%@", [self partnerKey]]];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&version=%@", OB_SDK_VERSION]];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&rand=%li", (long)randInteger]];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&widgetJSId=%@", request.widgetId]];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&idx=%li", (long)request.widgetIndex]];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&url=%@", [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    base = [base stringByAppendingString:[NSString stringWithFormat:@"&format=%@", @"vjnc"]];
    base = [base stringByAppendingString:([OBAppleAdIdUtil isOptedOut] ? @"" : [NSString stringWithFormat:@"&api_user_id=%@", [OBAppleAdIdUtil getAdvertiserId]])];
    base = [base stringByAppendingString:[((NSNumber *)[Outbrain mainBrain].settings[OBSettingsAttributes.testModeKey]) boolValue] ? @"&testMode=true" : @""];
    
    // Finally let's check whether or not we should append the apv value for this request
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
        [[[self mainBrain] settings] removeObjectForKey:key];
        return;
    }
    [[self mainBrain] settings][key] = value;
}

+ (id)OBSettingForKey:(NSString *)key
{
    return [[self mainBrain] settings][key];
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



