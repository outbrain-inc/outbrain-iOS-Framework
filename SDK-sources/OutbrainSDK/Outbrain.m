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
#import "OBUtils.h"
#import "OBViewabilityService.h"
#import "SFViewabilityService.h"
#import <UIKit/UIKit.h>


// The version of the sdk
NSString * const OB_SDK_VERSION     =   @"4.31.0";

NSString * const OB_AD_NETWORK_ID   =   @"97r2b46745.skadnetwork";

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
        [[OutbrainManager sharedInstance] reportPlistIsValidToServerIfNeeded];
        WAS_INITIALIZED = YES;
        NSLog(@"OutbrainSDK init");
    }
}

+ (void) setPartnerKey:(NSString *)partnerKey {
    [OutbrainManager sharedInstance].partnerKey = partnerKey;
}

+ (void) setUserId:(NSString *)userId {
    [OutbrainManager sharedInstance].customUserId = userId;
}

+ (BOOL) SDKInitialized {
    return WAS_INITIALIZED;
}

+ (void)setTestMode:(BOOL)testMode {
    [OutbrainManager sharedInstance].testMode = testMode;
}

+ (void)testRTB:(BOOL)testRTB {
    [OutbrainManager sharedInstance].testRTB = testRTB;
}

+ (void)testLocation:(NSString *)location {
    [OutbrainManager sharedInstance].testLocation = location;
}

+ (void)testAppInstall:(BOOL)testAppInstall {
    [OutbrainManager sharedInstance].testAppInstall = testAppInstall; 
}

+ (void)testBrandedCarousel:(BOOL)testBrandedCarousel {
    [OutbrainManager sharedInstance].testBrandedCarousel = testBrandedCarousel;
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
    OBRequest *obRequet = [OBRequest requestWithURL:url widgetID:widgetId];
    [self registerOBLabel:label withOBRequest:obRequet];
}

+ (void) registerOBLabel:(OBLabel * _Nonnull)label withOBRequest:(OBRequest * _Nonnull)obRequest {
    NSAssert([label isKindOfClass:[OBLabel class]], @"Outbrain - label must be of type OBLabel.");
    if (obRequest.widgetId == nil || [OBUtils getRequestUrl:obRequest] == nil) {
        NSLog(@"Outbrain Error: registerOBLabel() --> request url and widgetId must not be null");
        return;
    }
    
    label.obRequest = obRequest;
    
    if ([[OBViewabilityService sharedInstance] isViewabilityEnabled]) {
        [[OBViewabilityService sharedInstance] addOBLabelToMap:label];
        [label trackViewability];
    }
}

+ (void) configureViewabilityPerListingFor:(UIView * _Nonnull)view withRec:(OBRecommendation * _Nonnull)rec {
    [[SFViewabilityService sharedInstance] startReportViewabilityWithTimeInterval:2000]; // 2 seconds interval
    [[SFViewabilityService sharedInstance] configureViewabilityPerListingFor:view withRec:rec];
}

+(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inNavController:(UINavigationController * _Nonnull)navController {
    [self openAppInstallRec:rec inViewController:navController];
}
+(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inViewController:(UIViewController * _Nonnull)viewController {
    [[OutbrainManager sharedInstance] openAppInstallRec:rec inViewController:viewController];
}

@end








