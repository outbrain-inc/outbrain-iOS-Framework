//
//  OutbrainSDK.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/9/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "Outbrain.h"
#import "Outbrain_Private.h"
#import "OBContent_Private.h"

#import "OBRecommendationRequestOperation.h"
#import "OBDisclosure.h"
#import "OutbrainHelper.h"
#import "OBNetworkManager.h"

#import <UIKit/UIKit.h>


// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"2.5.2";

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


@end


@implementation Outbrain

#pragma GCC diagnostic ignored "-Wundeclared-selector"


#pragma mark - Initialization

+ (void)_throwAssertIfNotInitalized
{
    NSAssert([[OutbrainHelper sharedInstance] partnerKey] != nil, @"Please +initializeOutbrainWithConfigFile: before trying to use outbrain");
}

static dispatch_once_t once_token = 0;
static Outbrain * _sharedInstance = nil;

+ (instancetype)mainBrain
{
    dispatch_once(&once_token, ^{
        if (_sharedInstance == nil) {
            _sharedInstance = [[Outbrain alloc] init];
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
        [[OutbrainHelper sharedInstance] setSDKSettingValue:dict[OBSettingsAttributes.partnerKey] forKey:OBSettingsAttributes.partnerKey];
        
        WAS_INITIALISED = YES;
    }
}

+ (void)setTestMode:(BOOL)testMode {
    [[OutbrainHelper sharedInstance] setSDKSettingValue:[NSNumber numberWithBool:testMode] forKey:OBSettingsAttributes.testModeKey];
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

+ (NSURL *)getUrl:(OBRecommendation *)recommendation
{
    // Should be initialized
    [self _throwAssertIfNotInitalized];
    
    if (recommendation.isPaidLink) {
        NSString *recUrl = [recommendation originalValueForKeyPath:@"url"];
        return [NSURL URLWithString:recUrl];
    }
    else {
        // Organic Recommendation
        NSURL * originalURL = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"orig_url"]];
        NSString *urlString = [[recommendation originalValueForKeyPath:@"url"] stringByAppendingString:@"&noRedirect=true"];
        NSURL * urlWithRedirect = [NSURL URLWithString:urlString];
        
        // We don't need a completion block for this one.  We just need to fire off the request and let it do it's thing
        [[OBNetworkManager sharedManager] sendGet:urlWithRedirect completionHandler:nil];        
        return originalURL;
    }
}

+(NSURL *) getOutbrainAboutURL {
  NSString *base = [NSString stringWithFormat:@"https://www.outbrain.com/what-is/"];
  NSURLComponents *components = [NSURLComponents componentsWithString: base];
  components.queryItems = [[OutbrainHelper sharedInstance] advertiserIdURLParams];
  return components.URL;
}

#pragma mark - Viewability
+ (void) registerOBLabel:(OBLabel *)label withWidgetId:(NSString *)widgetId andUrl:(NSString *)url {
    NSAssert([label isKindOfClass:[OBLabel class]], @"Outbrain - label must be of type OBLabel.");
    if (url == nil) {
        NSLog(@"Error: registerOBLabel() --> url must not be null");
        return;
    }
    
    label.widgetId = widgetId;
    label.url = url;
    
    if (url != nil && widgetId != nil && [[OBViewabilityService sharedInstance] isViewabilityEnabled]) {
            [[OBViewabilityService sharedInstance] addOBLabelToMap:label];
            [label trackViewability];
    }
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
    static NSOperationQueue *odbFetchQueue = nil;
    if(!odbFetchQueue)
    {
        odbFetchQueue = [[NSOperationQueue alloc] init];
        odbFetchQueue.name = @"com.outbrain.sdk.odbFetchQueue";
        odbFetchQueue.maxConcurrentOperationCount = 1;
    }
    
    // This is where the magic happens
    // Let's first validate any parameters that we can.
    // AKA sanity checks
    if (![self _isValid:request.url] || ![self _isValid:request.widgetId]) {
        OBRecommendationResponse * response = [[OBRecommendationResponse alloc] init];
        response.error = [NSError errorWithDomain:OBNativeErrorDomain code:OBInvalidParametersErrorCode userInfo:@{@"msg" : @"Missing parameter in OBRequest"}];
        if(handler)
        {
            handler(response);
        }
        // If one of the parameters is not valid then create a response with an error and return here
        return;
    }
    
    OBRecommendationRequestOperation *recommendationOperation = [[OBRecommendationRequestOperation alloc] initWithRequest:request];
    recommendationOperation.handler = handler;
    [odbFetchQueue addOperation:recommendationOperation];
}

+ (BOOL) _isValid:(NSString *)value {
    return (value != nil && [value length] > 0);
}

@end






