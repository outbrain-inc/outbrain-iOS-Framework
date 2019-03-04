//
//  OBNetworkManager.m
//  OutbrainSDK
//
//  Created by oded regev on 10/9/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//


#import "OBNetworkManager.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "OBAppleAdIdUtil.h"



@interface OBNetworkManager()

@property (nonatomic, strong) NSString *userAgent;
@property (nonatomic, strong) NSURLSession *defaultSession;
@property (nonatomic, strong) WKWebView *wkWebview;
@end


@implementation OBNetworkManager

+ (id)sharedManager {
    static OBNetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.defaultSession = [NSURLSession sharedSession];
    });
    
    return sharedManager;
}


-(void) sendGet:(NSURL *)url completionHandler:(OBNetworkCompletionBlock)completionHandler {
    
    NSMutableURLRequest *request = [self generateMutableRequest:url];
    request.HTTPMethod = @"GET";
    
    NSURLSessionDataTask *getDataTask = [self.defaultSession dataTaskWithRequest:request
                                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                                   if (completionHandler) {
                                                                       completionHandler(data, response, error);
                                                                   }
                                                               }];
    [getDataTask resume];
}

-(void) sendPost:(NSURL *)url postData:(id)postDataDictionary completionHandler:(OBNetworkCompletionBlock)completionHandler
{
    NSMutableURLRequest *request = [self generateMutableRequest:url];
    
    if ([NSJSONSerialization isValidJSONObject:postDataDictionary]) {
        NSError *error;
        NSData *postData = [NSJSONSerialization dataWithJSONObject:postDataDictionary
                                                           options:0
                                                             error:&error];
        [request setHTTPBody: postData];
    }
    request.HTTPMethod = @"POST";
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionDataTask *postDataTask = [self.defaultSession
                                          dataTaskWithRequest:request
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (completionHandler) {
                                                  completionHandler(data, response, error);
                                              }
                                              
                                          }];
    
    [postDataTask resume];
}

#pragma mark - private methods
-(NSMutableURLRequest *) generateMutableRequest:(NSURL *)url {
    // Here we will ignore all cached data to ensure we attempt to make a request each time
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:15.f];
    
    if ([OBAppleAdIdUtil isOptedOut] || [OBAppleAdIdUtil didUserResetAdvertiserId]) {
        [OBAppleAdIdUtil refreshAdId];
    }
    [self addUserAgentHeaderTo:request];
    
    return request;
}

#pragma mark - User Agent

+ (NSString *) webviewUserAgent {
    if ([[self sharedManager] userAgent] == nil) {
        // Please note the waitUntilDone: YES
        [self performSelectorOnMainThread:@selector(createWebViewAndFetchUserAgent) withObject:nil waitUntilDone:YES];
    }
    
    return [[self sharedManager] userAgent];
}

+ (void) createWebViewAndFetchUserAgent {
    [[self sharedManager] setWkWebview: [[WKWebView alloc] initWithFrame:CGRectZero]];
    [[[self sharedManager] wkWebview] evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        NSString *userAgent = (NSString *)response;
        [[self sharedManager] setUserAgent:userAgent];
        [[self sharedManager] setWkWebview:nil];
    }];
}


- (void) addUserAgentHeaderTo:(NSMutableURLRequest *)request {
    [request setValue:[OBNetworkManager webviewUserAgent] forHTTPHeaderField:@"User-Agent"];
}

@end
