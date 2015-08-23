//
//  OBGAOperation.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/19/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBGAOperation.h"
#import "OBAppleAdIdUtil.h"

@implementation OBGAOperation
@synthesize connection = _connection;
@synthesize executing = _executing;
@synthesize finished = _finished;

#define GA_ACCOUNT @"UA-58446041-3"

#pragma mark - Initialize

- (instancetype)initWithMethodName:(NSString *)methodName withParams:(NSString *)params appKey:(NSString *)appKey appVersion:(NSString *)appVersion {
    self = [super init];
    if(self)
    {
        _methodName = methodName;
        _paramString = params;
        _appKey = appKey;
        _appVersion = appVersion;
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

// Here we'll go ahead and create the connection for our subclasses to use
- (void)main
{    
    NSString *idToReport = [OBAppleAdIdUtil isOptedOut] ? @"" : [OBAppleAdIdUtil getAdvertiserId];
    
    NSString *url = [NSString stringWithFormat:@"http://www.google-analytics.com/collect?t=event&v=1&tid=%@&cid=%@&ec=method&ea=%@&el=%@&de=UTF-8&an=%@&av=%@", GA_ACCOUNT, idToReport, _methodName, _paramString, _appKey, _appVersion];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.f];
    
    [request setHTTPShouldHandleCookies:YES];
    
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
