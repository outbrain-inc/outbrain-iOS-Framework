//
//  OBRecommendationsTokenHandler.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBRecommendationsTokenHandler.h"
#import "OBRequest.h"
#import "OBRecommendationResponse.h"

#define QUEUE_SIZE 5

#pragma mark Wrapper for Url and Token
@interface OBRecommendationsTokenWrapper : NSObject {
    NSString        *url;
    NSString        *token;
}

@property (nonatomic, copy) NSString        *url;
@property (nonatomic, copy) NSString        *token;

- (id)initWithUrl:(NSString *)url token:(NSString *)token;

@end

@implementation OBRecommendationsTokenWrapper
@synthesize url;
@synthesize token;

- (id)initWithUrl:(NSString *)aUrl token:(NSString *)aToken {
    self = [super init];
    if (self) {
        url = aUrl;
        token = aToken;
    }
    return self;
}

@end


#pragma mark Wrapper for Request and Response

@interface OBRequestResponseWrapper : NSObject {
    __weak OBRequest *request;
    __weak OBRecommendationResponse *response;
}

@property (nonatomic, weak) OBRequest *request;
@property (nonatomic, weak) OBRecommendationResponse *response;

- (id)initWithRequest:(OBRequest *)request response:(OBRecommendationResponse *)response;

@end

@implementation OBRequestResponseWrapper
@synthesize request;
@synthesize response;

- (id)initWithRequest:(OBRequest *)aRequest response:(OBRecommendationResponse *)aResponse {
    self = [super init];
    if (self) {
        request = aRequest;
        response = aResponse;
    }
    return self;
}

@end


@implementation OBRecommendationsTokenHandler

- (id)init {
    self = [super init];
    if (self) {
        tokensQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)getTokenForRequest:(OBRequest *)request {
    //If IDX is 0, return nil. Otherwise - search for the appropriate URL in the queue
    if (request.widgetIndex != 0) {
        for (OBRecommendationsTokenWrapper *token in tokensQueue) {
            if ([request.url isEqualToString:token.url]) {
                return token.token;
            }
        }
    }
    return nil;
}

- (void)setTokenForRequest:(OBRequest *)request response:(OBRecommendationResponse *)response {
    OBRecommendationsTokenWrapper *similarTokenInsideQueue = nil;

    //Handling when there is a token for the same URL
    for (OBRecommendationsTokenWrapper *tokenWrapper in tokensQueue) {
        if ([tokenWrapper.url isEqualToString:request.url]) {
            similarTokenInsideQueue = tokenWrapper;
            break;
        }
    }
    
    //Push the updated token to the top of the queue, or add a new one, if a token was not found
    if (similarTokenInsideQueue != nil) {
        int sizeOfQueue = [tokensQueue count];
        int i = 0;
        
        while ([tokensQueue count] > 0 && [tokensQueue objectAtIndex:0] != similarTokenInsideQueue) {
            OBRecommendationsTokenWrapper *token;
            
            //dequeue
            id headObject = [tokensQueue objectAtIndex:0];
            if (headObject != nil) {
                [tokensQueue removeObjectAtIndex:0];
            }
            
            //enqueue
            [tokensQueue addObject:headObject];
            i++;
        }
        
        OBRecommendationsTokenWrapper *token;
        
        id headObject = [tokensQueue objectAtIndex:0];
        if (headObject != nil) {
            [tokensQueue removeObjectAtIndex:0];
        }
        token = headObject;
        
        while (i < sizeOfQueue - 1) {
            //dequeue
            id headObject = [tokensQueue objectAtIndex:0];
            if (headObject != nil) {
                [tokensQueue removeObjectAtIndex:0];
            }
            
            //enqueue
            [tokensQueue addObject:headObject];
            i++;
        }
        // enqueue
        [tokensQueue addObject:token];
    }
    else {
        if ([tokensQueue count] > QUEUE_SIZE) {
            [tokensQueue removeObjectAtIndex:0];
        }
        
        OBRecommendationsTokenWrapper *tokenToWrite = [[OBRecommendationsTokenWrapper alloc] initWithUrl:request.url token:response.responseRequest.token];
        [tokensQueue addObject:tokenToWrite];
    }
    [self printQueue];
}

- (void)printQueue {
    for (int i = 0; i < [tokensQueue count]; i++) {
        //dequeue
        OBRecommendationsTokenWrapper *headObject = [tokensQueue objectAtIndex:i];
        NSLog(@"object %d = %@", i, headObject.url);
    }
}

@end
