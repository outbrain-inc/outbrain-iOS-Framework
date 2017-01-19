//
//  OBPostOperation.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/12/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBPostOperation.h"
#import "OBOperation.h"
#import <UIKit/UIKit.h>


@interface OBPostOperation()
{
    NSURL *_requestURL;
}

@end

@implementation OBPostOperation

#pragma mark - Initialize

+ (instancetype)operationWithURL:(NSURL *)url
{
    return [[[self class] alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if(self)
    {
        _requestURL = url;
    }
    return self;
}


- (void) main {
    NSError *error;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_requestURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.f];
    [self modifyUserAgent:request];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPMethod = @"POST";
    NSData *postData = [NSJSONSerialization dataWithJSONObject:self.postData options:0 error:&error];
    [request setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // The server answers with an error because it doesn't receive the params
    }];
    [postDataTask resume];
}

#pragma mark - Private Methods

- (void)modifyUserAgent:(NSMutableURLRequest *)request {
    [request setValue:[OBOperation webviewUserAgent] forHTTPHeaderField:@"User-Agent"];
}

@end
