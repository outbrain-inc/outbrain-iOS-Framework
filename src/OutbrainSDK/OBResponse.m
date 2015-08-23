//
//  OBResponse.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/18/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBResponse.h"
#import "OBGAHelper.h"

@implementation OBResponse

#pragma mark - Getters & Setters

- (OBRequest *)request {
    [OBGAHelper reportMethodCalled:@"OBResponse::getRequest"];
    return _request;
}

- (void)setRequest:(OBRequest *)aRequest {
    _request = aRequest;
}

- (NSError *)error {
    [OBGAHelper reportMethodCalled:@"OBResponse::getError"];
    return _error;
}

- (void)setError:(NSError *)anError {
    _error = anError;
}

- (NSError *)getPrivateError {
    return _error;
}

- (OBRequest *)getPrivateRequest {
    return _request;
}

@end
