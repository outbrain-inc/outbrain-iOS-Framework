//
//  OBOperation.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/23/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBOperation.h"
#import <UIKit/UIKit.h>
#import "OBAppleAdIdUtil.h"

@interface OBOperation()
{
    NSURL *_requestURL;
    NSURLSessionDataTask *_task;
    
    BOOL _isFinished;
    BOOL _isExecuting;
}

@end

@implementation OBOperation

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


#pragma mark - Operation Overrides

- (void)setFinished:(BOOL)isFinished
{
    if (isFinished != _isFinished) {
        [self willChangeValueForKey:@"isFinished"];
        // Instance variable has the underscore prefix rather than the local
        _isFinished = isFinished;
        [self didChangeValueForKey:@"isFinished"];
    }
}

- (BOOL)isFinished
{
    return _isFinished || [self isCancelled];
}

- (void)cancel
{
    [super cancel];
    if ([self isExecuting]) {
        [self setExecuting:NO];
        [self setFinished:YES];
    }
}

- (void)setExecuting:(BOOL)isExecuting {
    if (isExecuting != _isExecuting) {
        [self willChangeValueForKey:@"isExecuting"];
        _isExecuting = isExecuting;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (void)start
{
    if (![self isCancelled]) {
        [self setFinished:NO];
        [self setExecuting:YES];
        [self main];
    }
}


// Here we'll go ahead and create the connection for our subclasses to use
- (void)main
{
    
    // Here we will ignore all cached data to ensure we attempt to make a request each time
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:_requestURL cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.f];

    [request setHTTPShouldHandleCookies:![OBAppleAdIdUtil isOptedOut]];

    if ([OBAppleAdIdUtil isOptedOut] || [OBAppleAdIdUtil didUserResetAdvertiserId]) {
        for (NSHTTPCookie *cookie in [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies) {
            if ([cookie.domain rangeOfString:@"outbrain"].length != 0) {
                [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            }
        }
        [OBAppleAdIdUtil refreshAdId];
    }
    
    [self performSelectorOnMainThread:@selector(modifyUserAgent:) withObject:request waitUntilDone:YES];
    
    NSURLSession *session = [NSURLSession sharedSession];
    _task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      [self taskCompletedWith:data response:response error:error];
                                      [self setExecuting:NO];
                                      [self setFinished:YES];
                                  }];
    
    [_task resume];
}

- (void) taskCompletedWith:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    NSLog(@"This is an abstract method and should be overridden");
}


#pragma mark - Private Methods

- (void)modifyUserAgent:(NSMutableURLRequest *)request {
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    [request setValue:secretAgent forHTTPHeaderField:@"User-Agent"];
}


@end
