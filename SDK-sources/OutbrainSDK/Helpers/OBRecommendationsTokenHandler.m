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
    // If IDX is 0, return nil. Otherwise - return the token if exists for the url
    if (request.widgetIndex != 0) {
        return self.tokensDictionary[request.url];
    }
    
    return nil;
}

- (void)setTokenForRequest:(OBRequest *)request response:(OBRecommendationResponse *)response {
    if (self.tokensDictionary[request.url]) {
        if (request.widgetIndex == 0) {
            // Replacing token
            self.tokensDictionary[request.url] = response.responseRequest.token;
        }
        return;
    }
    else { // no token found for url, save the token
        self.tokensDictionary[request.url] = response.responseRequest.token;
    }

  
}

@end
