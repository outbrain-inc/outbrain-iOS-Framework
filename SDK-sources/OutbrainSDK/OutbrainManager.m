//
//  OutbrainManager.m
//  OutbrainSDK
//
//  Created by oded regev on 13/06/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

@import StoreKit;


#import "OutbrainManager.h"
#import "Outbrain.h"
#import "OBUtils.h"
#import "OBRecommendationRequestOperation.h"
#import "OBMultivacRequestOperation.h"
#import "OBRecommendationResponse.h"
#import "OBErrors.h"
#import "MultivacResponseDelegate.h"
#import "OBNetworkManager.h"
#import "OBSkAdNetworkData.h"
#import "OBContent_Private.h"

@interface OutbrainManager()

@property (nonatomic, strong) NSOperationQueue *odbFetchQueue;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation OutbrainManager

NSString * const OUTBRAIN_AD_NETWORK_ID = @"97r2b46745.skadnetwork";

NSString *const OUTBRAIN_URL_REPORT_PLIST_DATA = @"https://log.outbrainimg.com/api/loggerBatch/obsd_sdk_plist_stats";
NSString *const APP_USER_REPORTED_PLIST_TO_SERVER_KEY_FORMAT = @"REPORTED_PLIST_TO_SERVER_FOR_V_%@";
NSString *const USER_DEFAULT_PLIST_IS_VALID_VALUE = @"USER_DEFAULT_PLIST_IS_VALID_VALUE";

+(OutbrainManager *) sharedInstance {
    static OutbrainManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.odbFetchQueue = [[NSOperationQueue alloc] init];
        sharedInstance.odbFetchQueue.name = @"com.outbrain.sdk.odbFetchQueue";
        sharedInstance.odbFetchQueue.maxConcurrentOperationCount = 1;
        sharedInstance.userDefaults = [NSUserDefaults standardUserDefaults];
    });
    
    return sharedInstance;
}

- (void) fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler {
    
    NSAssert(self.partnerKey != nil, @"Please +initializeOutbrainWithPartnerKey: before trying to use outbrain");
    
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
    [self.odbFetchQueue addOperation:recommendationOperation];
}

- (void) fetchMultivacWithRequest:(OBRequest *)request andDelegate:(id<MultivacResponseDelegate>)multivacDelegate {
    OBMultivacRequestOperation *recommendationOperation = [[OBMultivacRequestOperation alloc] initWithRequest:request];
    recommendationOperation.multivacDelegate = multivacDelegate;
    [self.odbFetchQueue addOperation:recommendationOperation];
}

- (BOOL) _isValid:(NSString *)value {
    return (value != nil && [value length] > 0);
}


-(void) reportPlistIsValidToServerIfNeeded {
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [appVersionString stringByReplacingOccurrencesOfString:@" " withString:@""]; // sanity fix
    
    NSString *const APP_USER_REPORTED_PLIST_TO_SERVER_KEY = [NSString stringWithFormat: APP_USER_REPORTED_PLIST_TO_SERVER_KEY_FORMAT, appVersionString];
    // Check if already reported to server
    if ([self.userDefaults objectForKey:APP_USER_REPORTED_PLIST_TO_SERVER_KEY]) {
        NSLog(@"reportPlistIsValidToServerIfNeeded - user already reported to server (for key: %@) - is compliant?: %@", APP_USER_REPORTED_PLIST_TO_SERVER_KEY, [self.userDefaults objectForKey:USER_DEFAULT_PLIST_IS_VALID_VALUE]);
#ifdef DEBUG
        [self checkIfSkAdNetworkIsConfiguredCorrectly];
#endif
        return;
    }
    
    // Prepare params to send to server
    BOOL isPlistConfiguredOk = [self checkIfSkAdNetworkIsConfiguredCorrectly];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSTimeInterval intervalUnixTime = [[NSDate date] timeIntervalSince1970];
    NSInteger timeNow = intervalUnixTime;
    
    NSMutableDictionary *paramsDict = [@{} mutableCopy];
    paramsDict[@"timestamp"] = [NSString stringWithFormat:@"%@", @(timeNow)];
    paramsDict[@"appId"] = bundleIdentifier;
    paramsDict[@"appVersion"] = appVersionString;
    paramsDict[@"sdkVersion"] = OB_SDK_VERSION;
    paramsDict[@"isCompliant"] = isPlistConfiguredOk ? @"true" : @"false";
    NSArray *paramsArray = @[paramsDict];
    
    // Report to server
    // NSLog(@"reportPlistIsValidToServerIfNeeded - send POST %@ with params: %@", OUTBRAIN_URL_REPORT_PLIST_DATA, paramsArray);
    NSURL *reportUrl = [NSURL URLWithString: OUTBRAIN_URL_REPORT_PLIST_DATA];
    [[OBNetworkManager sharedManager] sendPost:reportUrl postData:paramsArray completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"reportPlistIsValidToServerIfNeeded - error: %@", error);
            return;
        }

        // handle HTTP errors here
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
            NSLog(@"reportPlistIsValidToServerIfNeeded - HTTP status code: %d", statusCode);
            if (statusCode != 200) {
                return;
            }
            else {
                [self.userDefaults setObject:@YES forKey: APP_USER_REPORTED_PLIST_TO_SERVER_KEY];
                [self.userDefaults setObject:paramsDict[@"isCompliant"] forKey: USER_DEFAULT_PLIST_IS_VALID_VALUE];
            }
        }
    }];
}

-(BOOL) checkIfSkAdNetworkIsConfiguredCorrectly {
    NSArray *SKAdNetworkItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SKAdNetworkItems"];
    for (NSDictionary *entry in SKAdNetworkItems) {
        NSString *adNetworkId = entry[@"SKAdNetworkIdentifier"];
        if ([OUTBRAIN_AD_NETWORK_ID isEqualToString:adNetworkId]) {
            NSLog(@"** Outbrain SKAdNetworkIdentifier is configured in plist ***");
            return YES;
        }
    }
    NSLog(@"** Outbrain SKAdNetworkIdentifier NOT configured in plist (iOS version >= 14.0)");
    return NO;
}

-(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inNavController:(UINavigationController * _Nonnull)navController {
    BOOL isDeviceSimulator = [OBUtils isDeviceSimulator];
    if (isDeviceSimulator) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"App Install Error"
                                                                                 message:@"App Install should be opened with loadProduct() which is not avialable on Simulator"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //We add buttons to the alert controller by creating UIAlertActions:
        UIAlertAction *actionOk = [UIAlertAction actionWithTitle:@"Ok"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil]; //You can use a block here to handle a press on this button
        [alertController addAction:actionOk];
        [navController presentViewController:alertController animated:YES completion:nil];
    }
    else if (@available(iOS 11.3, *)) {
        // First call paid.outbrain with noRedirect=true
        NSString *paidUrlString = [[rec originalValueForKeyPath:@"url"] stringByAppendingString:@"&noRedirect=true"];
        NSURL * paidUrlRedirectFalse = [NSURL URLWithString:paidUrlString];
        [[OBNetworkManager sharedManager] sendGet:paidUrlRedirectFalse completionHandler:nil];
        
        SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
        NSMutableDictionary* productParameters = [[NSMutableDictionary alloc] init];
        
        [productParameters setObject: rec.skAdNetworkData.iTunesItemId    forKey: SKStoreProductParameterITunesItemIdentifier];
        [productParameters setObject: rec.skAdNetworkData.adNetworkId     forKey: SKStoreProductParameterAdNetworkIdentifier];
        [productParameters setObject: rec.skAdNetworkData.signature       forKey: SKStoreProductParameterAdNetworkAttributionSignature];
        
        // timestamp and campaignId must be valid
        if (rec.skAdNetworkData.timestamp > 0 && [rec.skAdNetworkData.campaignId isKindOfClass: [NSNumber class]]) {
            [productParameters setObject: @(rec.skAdNetworkData.timestamp) forKey: SKStoreProductParameterAdNetworkTimestamp];
            [productParameters setObject: @([rec.skAdNetworkData.campaignId intValue])    forKey: SKStoreProductParameterAdNetworkCampaignIdentifier];
        }
        
        if (@available(iOS 14, *)) {
            // These product params are only included in SKAdNetwork version 2.0
            if ([rec.skAdNetworkData.skNetworkVersion isEqualToString:@"2.0"]) {
                 [productParameters setObject: @"2.0"     forKey: SKStoreProductParameterAdNetworkVersion];
                 [productParameters setObject: rec.skAdNetworkData.sourceAppId     forKey: SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
            }
        }
        
        [productParameters setObject:[[NSUUID alloc] initWithUUIDString:rec.skAdNetworkData.nonce] forKey:SKStoreProductParameterAdNetworkNonce];

        
        NSLog(@"loadProductWithParameters: %@", productParameters);
        [storeViewController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError * _Nullable error) {
            // result -  true if the product information was successfully loaded, otherwise false.
            NSLog(@"loadProductWithParameters - result: %@, error: %@", result ? @"true" : @"false", [error localizedDescription]);
        }];
        [navController presentViewController:storeViewController animated:YES completion:nil];
    }
}

@end
