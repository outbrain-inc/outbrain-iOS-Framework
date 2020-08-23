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


@interface OutbrainManager()

@property (nonatomic, strong) NSOperationQueue *odbFetchQueue;

@end

@implementation OutbrainManager

+(OutbrainManager *) sharedInstance {
    static OutbrainManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.odbFetchQueue = [[NSOperationQueue alloc] init];
        sharedInstance.odbFetchQueue.name = @"com.outbrain.sdk.odbFetchQueue";
        sharedInstance.odbFetchQueue.maxConcurrentOperationCount = 1;
        [sharedInstance publisherAppPlistValid];
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

-(BOOL) publisherAppPlistValid {
    NSArray *SKAdNetworkItems = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SKAdNetworkItems"];
    for (NSDictionary *entry in SKAdNetworkItems) {
        NSString *adNetworkId = entry[@"SKAdNetworkIdentifier"];
        if ([OB_AD_NETWORK_ID isEqualToString:adNetworkId]) {
            NSLog(@"** Outbrain SKAdNetworkIdentifier is configured in plist ***");
            return YES;
        }
    }
    NSLog(@"** Outbrain SKAdNetworkIdentifier NOT configured in plist (iOS version >= 14.0)");
    return NO;
}

-(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inNavController:(UINavigationController * _Nonnull)navController {
    BOOL isDeviceSimulator = [OBUtils isDeviceSimulator];
    if (@available(iOS 11.3, *) && !isDeviceSimulator) {
        SKStoreProductViewController *storeViewController = [[SKStoreProductViewController alloc] init];
        NSMutableDictionary* productParameters = [[NSMutableDictionary alloc] init];
        [productParameters setObject: rec.appInstallItunesItemIdentifier forKey:SKStoreProductParameterITunesItemIdentifier];
        [productParameters setObject: OB_AD_NETWORK_ID forKey:SKStoreProductParameterAdNetworkIdentifier];
        if (@available(iOS 14, *)) {
            // [productParameters setObject:@"2.0" forKey:SKStoreProductParameterAdNetworkVersion];
            // [[productParameters setObject:@"342432" forKey:forKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier];
        }
        NSLog(@"loadProductWithParameters: %@", productParameters);
        [storeViewController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError * _Nullable error) {
            // result -  true if the product information was successfully loaded, otherwise false.
            NSLog(@"loadProductWithParameters - result: %@, error: %@", result ? @"true" : @"false", [error localizedDescription]);
        }];
        [navController presentViewController:storeViewController animated:YES completion:nil];
    }
    else if (isDeviceSimulator) {
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
}

@end
