//
//  OutbrainManager.m
//  OutbrainSDK
//
//  Created by oded regev on 13/06/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "OutbrainManager.h"
#import "Outbrain.h"
#import "OBPlatformRequest.h"
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
    });
    return sharedInstance;
}

- (void) fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler {
    
    NSAssert(self.partnerKey != nil, @"Please +initializeOutbrainWithPartnerKey: before trying to use outbrain");

    if ([self isOBRequestMissingParam:request]) {
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

- (BOOL) isOBRequestMissingParam:(OBRequest *)request {
    BOOL isPlatfromRequest = [request isKindOfClass:[OBPlatformRequest class]];
    
    if (isPlatfromRequest) {
        OBPlatformRequest *platformRequest = (OBPlatformRequest *)request;
        BOOL missingParam = (![self _isValid:platformRequest.bundleUrl] && ![self _isValid:platformRequest.portalUrl]);
        return missingParam || ![self _isValid:request.widgetId] || ![self _isValid:platformRequest.lang];
    }
    else if (![self _isValid:request.url] || ![self _isValid:request.widgetId]) {
        return YES;
    }
    
    return NO;
}

- (void) fetchMultivacWithRequest:(OBRequest *)request andDelegate:(id<MultivacResponseDelegate>)multivacDelegate {
    OBMultivacRequestOperation *recommendationOperation = [[OBMultivacRequestOperation alloc] initWithRequest:request];
    recommendationOperation.multivacDelegate = multivacDelegate;
    [self.odbFetchQueue addOperation:recommendationOperation];
}

- (BOOL) _isValid:(NSString *)value {
    return (value != nil && [value length] > 0);
}
@end
