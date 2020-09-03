//
//  OutbrainManager.m
//  OutbrainSDK
//
//  Created by oded regev on 13/06/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "OutbrainManager.h"
#import "Outbrain.h"
#import "OBRecommendationRequestOperation.h"
#import "OBMultivacRequestOperation.h"
#import "OBRecommendationResponse.h"
#import "OBErrors.h"
#import "MultivacResponseDelegate.h"
#import "OBNetworkManager.h"

@interface OutbrainManager()

@property (nonatomic, strong) NSOperationQueue *odbFetchQueue;
@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation OutbrainManager

NSString * const OUTBRAIN_AD_NETWORK_ID = @"97r2b46745.skadnetwork";

NSString *const OUTBRAIN_URL_REPORT_PLIST_DATA = @"https://log.outbrainimg.com/api/loggerBatch/obsd_sdk_plist_stats";
NSString *const APP_USER_REPORTED_PLIST_TO_SERVER_KEY_FORMAT = @"APP_USER_REPORTED_PLIST_TO_SERVER_FOR_APPVER_%@_KEY";

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
        NSLog(@"reportPlistIsValidToServerIfNeeded - user already reported to server (for key: %@)", APP_USER_REPORTED_PLIST_TO_SERVER_KEY);
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
    NSLog(@"reportPlistIsValidToServerIfNeeded - send POST %@ with params: %@", OUTBRAIN_URL_REPORT_PLIST_DATA, paramsArray);
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
            }
        }

        // otherwise, everything is probably fine and you should interpret the `data` contents
        NSLog(@"reportPlistIsValidToServerIfNeeded - response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
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
 
@end
