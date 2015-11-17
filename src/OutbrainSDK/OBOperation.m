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
}

@end

@implementation OBOperation
@synthesize connection = _connection;
@synthesize executing = _executing;
@synthesize finished = _finished;

#pragma mark - Initialize

+ (instancetype)operationWithURL:(NSURL *)url
{
    NSString *urlString = [[url absoluteString] stringByAppendingString:@"&noRedirect=true"];
    
    return [[[self class] alloc] initWithURL:[NSURL URLWithString:urlString]];
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


#pragma mark - Special

// May want to change this around later on.
// Since the subclasses handle url connections by setting the run
// loop.  We'll allow the ability to change that here
- (NSRunLoop *)operationRunLoop
{
    return [NSRunLoop mainRunLoop];
}


#pragma mark - Operation Overrides

- (void)start
{
    // Always check for cancellation before launching the task.
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        return [self setFinished:YES];
    }
    
    // If the operation is not canceled, begin executing the task.
    [self setExecuting:YES];
    
    // If we called `-start` directly on the main thread,
    // then let's handle it, and put it on a background thread
    if([NSThread isMainThread])
    {
        [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    }
    else
    {
        [self main];
    }
}

- (void)modifyUserAgent:(NSMutableURLRequest *)request {
    UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString* secretAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    
    [request setValue:secretAgent forHTTPHeaderField:@"User-Agent"];
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
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[self operationRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)cancel
{
    [_connection unscheduleFromRunLoop:[self operationRunLoop] forMode:NSRunLoopCommonModes];
    [_connection cancel];
    _connection = nil;
    [super cancel];
}


#pragma mark - Setters

- (void)setFinished:(BOOL)finished
{
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
    if(finished)
    {
        [self setExecuting:NO];
    }
}

- (void)setExecuting:(BOOL)executing
{
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}


#pragma mark - Getters

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isExecuting
{
    return _executing;
}


#pragma mark - Memory

- (void)dealloc
{
    if(_connection)
    {
        [_connection unscheduleFromRunLoop:[self operationRunLoop] forMode:NSRunLoopCommonModes];
        [_connection cancel];
        _connection = nil;
    }
}

@end
