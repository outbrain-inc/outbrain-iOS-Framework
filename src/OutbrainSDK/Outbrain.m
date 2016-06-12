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
#import "OBLabel.h"
#import "OBAppleAdIdUtil.h"
#import "OBViewabilityService.h"

#import <UIKit/UIKit.h>
#import <sys/utsname.h>

// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"2.0";

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
    .testModeKey                = @"OB_TEST_MODE_KEY"

};

@interface Outbrain()

@property (nonatomic, strong) NSMutableDictionary * apvCache;

@end


@implementation Outbrain

NSString *const kGLOBAL_WIDGET_STATISTICS = @"globalWidgetStatistics";
NSString *const kVIEWABILITY_THRESHOLD = @"ViewabilityThreshold";

#pragma mark - Initialization

+ (void)_throwAssertIfNotInitalized
{
    NSAssert([self partnerKey] != nil, @"Please +initializeOutbrainWithConfigFile: before trying to use outbrain");
}

static dispatch_once_t once_token = 0;
static Outbrain * _sharedInstance = nil;

+ (instancetype)mainBrain
{
    dispatch_once(&once_token, ^{
        if (_sharedInstance == nil) {
            _sharedInstance = [[Outbrain alloc] init];
            _sharedInstance.obSettings = [[NSMutableDictionary alloc] init];
            _sharedInstance.apvCache = [[NSMutableDictionary alloc] init];   // Initialize our apv cache.
            NSOperationQueue * queue = [[NSOperationQueue alloc] init];
            [queue setName:@"Outbrain Operation Queue"];
            queue.maxConcurrentOperationCount = 1;  // Serial
            _sharedInstance.obRequestQueue = queue;
            [OBViewabilityService sharedInstance].obRequestQueue = queue; // Share the operation queue with OBViewabilityService
            _sharedInstance.tokensHandler = [[OBRecommendationsTokenHandler alloc] init];
            _sharedInstance.viewabilityService = [[OBViewabilityService alloc] init];

        }
    });
    
    return _sharedInstance;
}

// Used in Tests only
+ (void)setSharedInstance:(Outbrain *)instance {
    once_token = 0; // resets the once_token so dispatch_once will run again
    WAS_INITIALISED = NO;
    _sharedInstance = instance;
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
    }
}

+ (void)initializeOutbrainWithPartnerKey:(NSString *)partnerKey {
    if (!WAS_INITIALISED) {
        // Finally set the settings payload.
        [self initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:partnerKey}];
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
        WAS_INITIALISED = YES;
    }
}

+ (void)setTestMode:(BOOL)testMode {
    [[[self mainBrain] obSettings] setValue:[NSNumber numberWithBool:testMode] forKey:OBSettingsAttributes.testModeKey];
}

#pragma mark - Fetching

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withCallback:(OBResponseCompletionHandler)handler
{
    [self _fetchRecommendationsWithRequest:request andCallback:handler];
}

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withDelegate:(__weak id<OBResponseDelegate>)delegate
{
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
    // Should be initialized
    [self _throwAssertIfNotInitalized];
    
    // New feature!! if SDK_SHOULD_RETURN_PAID_REDIRECT_URL == YES return the redirect url
    BOOL sdkShouldReturnPaidRedirectUrl = [[recommendation originalValueForKeyPath:kSDK_SHOULD_RETURN_PAID_REDIRECT_URL] boolValue];
    if (sdkShouldReturnPaidRedirectUrl && [recommendation isPaidLink]) {
        return [NSURL URLWithString:[recommendation originalValueForKeyPath:@"url"]];
    }
    
    // else... back to original implementation
    
    NSURL * originalURL = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"orig_url"]];
    
    NSString *urlString = [[recommendation originalValueForKeyPath:@"url"] stringByAppendingString:@"&noRedirect=true"];
    NSURL * urlWithRedirect = [NSURL URLWithString:urlString];
    
    // We don't need a completion block for this one.  We just need to fire off the request and let it do it's thing
    OBClickRegistrationOperation *clickOP = [OBClickRegistrationOperation operationWithURL:urlWithRedirect];
    [[[self mainBrain] obRequestQueue] addOperation:clickOP];
    
    return originalURL;
}

#pragma mark - Viewability
+ (void) registerOBLabel:(OBLabel *)label withWidgetId:(NSString *)widgetId andUrl:(NSString *)url {
    label.widgetId = widgetId;
    label.url = url;
    if (url != nil && widgetId != nil && [[OBViewabilityService sharedInstance] isViewabilityEnabled]) {
            [[OBViewabilityService sharedInstance] addOBLabelToMap:label];
            [label trackViewability];
    }
}

#pragma mark - Custom OBWebView
+ (BOOL) isOutbrainPaidUrl:(NSURL *)url {
    NSString *currentUrl = [url absoluteString];
    return [currentUrl containsString:@"paid.outbrain.com/network/redir"];
}

+ (BOOL) shouldOpenUrlInSafariViewController:(NSURL *)url {
    return NO;
}

#if 0 // For the current SDK version the GA reporting should be disabled
+ (void)trackSDKUsage:(BOOL)shouldTrackSDKUsage {
    [OBGAHelper reportMethodCalled:@"setShouldTrackSDKUsage:" withParams:(shouldTrackSDKUsage ? @"YES" : @"NO"), nil];
    [OBGAHelper setShouldReportSDKUsage:shouldTrackSDKUsage];
}
#endif 

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
            response.error = [NSError errorWithDomain:OBNativeErrorDomain code:OBInvalidParametersErrorCode userInfo:@{@"msg" : @"Missing parameter in OBRequest"}];
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
        [__self _updateViewbilityStatsForResponse:response];
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
        }
    }
    return filteredResponse;
}

+ (void)_updateViewbilityStatsForResponse:(OBResponse *)response {
    NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    BOOL globalStatsEnabled = YES;
    int viewabilityThreshold = 0;
    
    // We only update our viewability values in the case that the response did not error.
    if([response performSelector:@selector(getPrivateError)]) return;
    
    // Sanity
    if ((responseSettings == nil) || ![responseSettings isKindOfClass:[NSDictionary class]]) {
        return;
    }
        
    if (responseSettings[kGLOBAL_WIDGET_STATISTICS] && ![responseSettings[kGLOBAL_WIDGET_STATISTICS] isKindOfClass:[NSNull class]])
    {
        globalStatsEnabled = [responseSettings[kGLOBAL_WIDGET_STATISTICS] boolValue];
        [[OBViewabilityService sharedInstance] updateViewabilitySetting:[NSNumber numberWithBool:globalStatsEnabled] key:kViewabilityEnabledKey];
    }
    
    if (responseSettings[kVIEWABILITY_THRESHOLD] && ![responseSettings[kVIEWABILITY_THRESHOLD] isKindOfClass:[NSNull class]])
    {
        viewabilityThreshold = [responseSettings[kVIEWABILITY_THRESHOLD] intValue];        
        [[OBViewabilityService sharedInstance] updateViewabilitySetting:[NSNumber numberWithInt:viewabilityThreshold] key:kViewabilityThresholdKey];
    }
}

+ (void)_updateAPVCacheForResponse:(OBResponse *)response
{
    NSDictionary * responseSettings = [response originalValueForKeyPath:@"settings"];
    BOOL apvReturnValue = NO;

    // We only update our apv value in the case that the response did not error.
    if([response performSelector:@selector(getPrivateError)]) return;
    
    OBRequest *request = [response performSelector:@selector(getPrivateRequest)];
    if (request == nil) return; // sanity
    
    NSString *requestUrl = request.url;
    
    // If apv = true we don't want to set anything;
    if (_sharedInstance.apvCache[requestUrl] && ([_sharedInstance.apvCache[requestUrl] boolValue] == YES)) {
        return;
    }
    
    if (responseSettings && [responseSettings isKindOfClass:[NSDictionary class]] && responseSettings[@"apv"] && ![responseSettings[@"apv"] isKindOfClass:[NSNull class]])
    {
        apvReturnValue = [responseSettings[@"apv"] boolValue];
    }
    
    // If apvReturnValue is false we don't want to set anything
    if (apvReturnValue == NO) return;
 
    // Finally, if we got here, we need to save the apv value to the apvCache
    _sharedInstance.apvCache[requestUrl] = [NSNumber numberWithBool:apvReturnValue]; // apvReturnValue mush be equal to YES;
}

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
        
        if(request.mobileId && request.mobileId.length > 0) {
            [urlString appendFormat:@"%@additionalData=%@", parameterDelimiter, request.mobileId];
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
        
        if(request.source && request.source.length > 0) {
            [urlString appendFormat:@"%@mobileSubGroup=%@", parameterDelimiter, request.source];
        }
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
    base = [base stringByAppendingString:[((NSNumber *)[Outbrain mainBrain].obSettings[OBSettingsAttributes.testModeKey]) boolValue] ? @"&testMode=true" : @""];
    
    //Installation type
    base = [base stringByAppendingString:[((NSNumber *)[Outbrain mainBrain].obSettings[OBSettingsAttributes.testModeKey]) boolValue] ? @"&installationType=ios_sdk" : @""];
    
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
    NSString *token = [((Outbrain *)[self mainBrain]).tokensHandler getTokenForRequest:request];
    base = [base stringByAppendingString:(token == nil ? @"" : [NSString stringWithFormat:@"&t=%@", token])];
    
    // APV
    if(request.widgetIndex == 0) { // Reset APV on index = 0
        _sharedInstance.apvCache[request.url] = [NSNumber numberWithBool:NO];
    }
    if ([_sharedInstance.apvCache[request.url] boolValue]) {
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