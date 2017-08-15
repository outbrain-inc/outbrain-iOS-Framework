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

#import "OBClickRegistrationOperation.h"
#import "OBRecommendationRequestOperation.h"
#import "OBDisclosure.h"
#import "OutbrainHelper.h"

#import <UIKit/UIKit.h>


// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"2.2.0";

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
            NSOperationQueue * queue = [[NSOperationQueue alloc] init];
            [queue setName:@"Outbrain Operation Queue"];
            queue.maxConcurrentOperationCount = 1;  // Serial
            _sharedInstance.obRequestQueue = queue;
            [OBViewabilityService sharedInstance].obRequestQueue = queue; // Share the operation queue with OBViewabilityService
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
        NSString *const kCWVContextParam = [NSString stringWithFormat:@"#%@sdk", kCWV_CONTEXT_FLAG];
        // Adding "#cwvContext=sdk" to the url
        NSString *recUrl = [[recommendation originalValueForKeyPath:@"url"] stringByAppendingString:kCWVContextParam];
        return [NSURL URLWithString:recUrl];
    }
    else {
        // Organic Recommendation
        
        NSURL * originalURL = [NSURL URLWithString:[recommendation originalValueForKeyPath:@"orig_url"]];
        NSString *urlString = [[recommendation originalValueForKeyPath:@"url"] stringByAppendingString:@"&noRedirect=true"];
        NSURL * urlWithRedirect = [NSURL URLWithString:urlString];
        
        // We don't need a completion block for this one.  We just need to fire off the request and let it do it's thing
        OBClickRegistrationOperation *clickOP = [OBClickRegistrationOperation operationWithURL:urlWithRedirect];
        [[[self mainBrain] obRequestQueue] addOperation:clickOP];
        
        return originalURL;
    }
}

#pragma mark - RTB integratin with SDK
+(void) prepare:(UIImageView *)imageView withRTB:(OBRecommendation *)rec onClickBlock:(OBOnClickBlock)block {
    //UIButton *adChoicesButton = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
    UIButton *adChoicesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    adChoicesButton.userInteractionEnabled = YES;
    adChoicesButton.frame = CGRectMake(5, 5, 40, 40);
    // add on click listener
    [adChoicesButton addTarget:[OutbrainHelper sharedInstance] action:@selector(adChoicesClick:) forControlEvents:UIControlEventTouchUpInside];
    
    // add on click listener
    [adChoicesButton addTarget:[Outbrain class] action:@selector(adChoicesClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // Load Ad Choices image url
    UIImageView * __weak weakImageView = imageView;
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSURL *url = [NSURL URLWithString:rec.disclosure.imageUrl];
        if (url == nil) {
            return;
        }
        NSData * data = [[NSData alloc] initWithContentsOfURL: url];
        if ( data == nil ) {
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakImageView != nil) {
               // [adChoicesButton setImage:[UIImage imageWithData: data] forState:UIControlStateNormal];
                [weakImageView addSubview:adChoicesButton];
                
            }
        });
    });
}

+(void)adChoicesClick:(id)sender {
    NSLog(@"single Tap on Ad Choices view");
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
    
    OBRecommendationRequestOperation *recommendationOperation = [OBRecommendationRequestOperation operationWithURL:[[OutbrainHelper sharedInstance] recommendationURLForRequest:request]];
    recommendationOperation.request = request;
    
    // No retain cycles here
    typeof(recommendationOperation) __weak __recommendationOperation = recommendationOperation;
    typeof(self) __weak __self = self;
    
    [recommendationOperation setCompletionBlock:^{
        
        // Here we update Settings from the respones
        OBRecommendationResponse * response = __recommendationOperation.response;
        [[OutbrainHelper sharedInstance] updateODBSettings:response];
        
        response.recommendations = [__self _filterInvalidRecsForResponse:response];
        [[OutbrainHelper sharedInstance].tokensHandler setTokenForRequest:request response:response];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(handler)
            {
                handler(response);
            }
        });
    }];
    
    [[[self mainBrain] obRequestQueue] addOperation:recommendationOperation];
}

+ (BOOL) _isValid:(NSString *)value {
    return (value != nil && [value length] > 0);
}

+ (NSArray *)_filterInvalidRecsForResponse:(OBRecommendationResponse *)response {
    NSMutableArray *filteredResponse = [[NSMutableArray alloc] init];
    for (OBRecommendation *rec in response.recommendations) {
        if (rec.isPaidLink) {
            [filteredResponse addObject:rec];
        }
        else {
            // Organic
            NSString *stringUrl = [rec performSelector:@selector(originalValueForKeyPath:) withObject:@"orig_url"];
            NSURL *url = [NSURL URLWithString:stringUrl];
            if (url) {
                [filteredResponse addObject:rec];
            }
        }
    }
    return filteredResponse;
}

@end






