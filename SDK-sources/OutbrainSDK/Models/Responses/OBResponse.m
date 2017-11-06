//
//  OBResponse.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/18/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBResponse.h"

@implementation OBResponse

#pragma mark - Getters & Setters

- (OBRequest *)request {
    return _request;
}

- (void)setRequest:(OBRequest *)aRequest {
    _request = aRequest;
}

- (NSError *)error {
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
