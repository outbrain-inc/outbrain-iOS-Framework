 //
//  OBRecommendationsTokenHandler.m
//  OutbrainSDK
//
//  Created by Oded Regev on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBRecommendationsTokenHandler.h"
#import "OBRequest.h"
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
    
    return self.tokensDictionary[request.url];
}

- (void)setTokenForRequest:(OBRequest *)request response:(OBRecommendationResponse *)response {
    self.tokensDictionary[request.url] = response.responseRequest.token;
}

@end
