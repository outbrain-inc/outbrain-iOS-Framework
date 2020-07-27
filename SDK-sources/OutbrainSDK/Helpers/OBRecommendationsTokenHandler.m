 //
//  OBRecommendationsTokenHandler.m
//  OutbrainSDK
//
//  Created by Oded Regev on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBRecommendationsTokenHandler.h"
#import "OBRequest.h"
#import "OBPlatformRequest.h"
#import "OBRecommendationResponse.h"


#pragma mark Wrapper for Request and Response

@interface OBRequestResponseWrapper : NSObject

@property (nonatomic, weak) OBRequest *request;
@property (nonatomic, weak) OBRecommendationResponse *response;

- (id)initWithRequest:(OBRequest *)request response:(OBRecommendationResponse *)response;

@end



@implementation OBRequestResponseWrapper

- (id)initWithRequest:(OBRequest *)aRequest response:(OBRecommendationResponse *)aResponse {
    self = [super init];
    if (self) {
        self.request = aRequest;
        self.response = aResponse;
    }
    return self;
}

@end

@interface OBRecommendationsTokenHandler()

@property (nonatomic, strong) NSMutableDictionary *tokensDictionary;

@end


@implementation OBRecommendationsTokenHandler

- (id)init {
    self = [super init];
    if (self) {
        self.tokensDictionary = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSString *)getTokenForRequest:(OBRequest *)request {
    if (request.widgetIndex == 0 && !request.isMultivac) {
        return nil;
    }
    
    NSString *requestUrl = [self getRequestUrl:request];
    return self.tokensDictionary[requestUrl];
}

- (void)setTokenForRequest:(OBRequest *)request response:(OBRecommendationResponse *)response {
    NSString *requestUrl = [self getRequestUrl:request];
    self.tokensDictionary[requestUrl] = response.responseRequest.token;
}

-(NSString *) getRequestUrl:(OBRequest *)request {
    BOOL isPlatfromRequest = [request isKindOfClass:[OBPlatformRequest class]];
    if (isPlatfromRequest) {
        OBPlatformRequest *req = (OBPlatformRequest *)request;
        return req.bundleUrl ? req.bundleUrl : req.portalUrl;
    }
    else {
        return request.url;
    }
}

@end
