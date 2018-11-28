//
//  OutbrainSDK.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/9/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "Outbrain.h"
#import "OBContent_Private.h"
#import "OBErrors.h"
#import "OutbrainManager.h"
#import "OBDisclosure.h"
#import "OutbrainHelper.h"
#import "OBNetworkManager.h"
#import "OBLabel.h"
#import "OBViewabilityService.h"
#import <UIKit/UIKit.h>


// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"3.4.2";

BOOL WAS_INITIALIZED     =   NO;


@interface Outbrain()


@end


@implementation Outbrain

#pragma GCC diagnostic ignored "-Wundeclared-selector"


#pragma mark - Initialization

+ (void)_throwAssertIfNotInitalized
{
    NSAssert(WAS_INITIALIZED, @"Please +initializeOutbrainWithPartnerKey: before trying to use outbrain");
}

+ (void)initializeOutbrainWithPartnerKey:(NSString *)partnerKey {
    if (!WAS_INITIALIZED) {
        // Finally set the settings payload.
        NSAssert(partnerKey != nil, @"Partner Key Must not be nil");
        NSAssert([partnerKey length] > 0, @"Partner Key Must not be empty string");
        [OutbrainManager sharedInstance].partnerKey = partnerKey;
        WAS_INITIALIZED = YES;
        NSLog(@"OutbrainSDK init");
    }
}

+ (BOOL) SDKInitialized {
    return WAS_INITIALIZED;
}

+ (void)setTestMode:(BOOL)testMode {
    [OutbrainManager sharedInstance].testMode = testMode;
}

#pragma mark - Fetching

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withCallback:(OBResponseCompletionHandler)handler
{
    @synchronized ([OutbrainManager sharedInstance]) {
        [[OutbrainManager sharedInstance] fetchRecommendationsWithRequest:request andCallback:handler];
    }
}

+ (void)fetchRecommendationsForRequest:(OBRequest *)request withDelegate:(__weak id<OBResponseDelegate>)delegate
{
    @synchronized ([OutbrainManager sharedInstance]) {
        [[OutbrainManager sharedInstance] fetchRecommendationsWithRequest:request andCallback:^(OBRecommendationResponse *response) {
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








