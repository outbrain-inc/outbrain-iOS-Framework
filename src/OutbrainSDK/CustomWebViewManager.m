//
//  CustomWebViewManager.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/23/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "CustomWebViewManager.h"
#import "OBReachability.h"
#import "OBPostOperation.h"
#import "Outbrain.h"

@interface CustomWebViewManager()
@property (nonatomic, strong) NSOperationQueue * obRequestQueue;    // Our operation queue

@property (nonatomic, assign) BOOL alreadyReportedOnPercentLoad;
@property (nonatomic, assign) BOOL alreadyReportedOnLoadComplete;


@property (nonatomic, strong) NSString *paidOutbrainParams;
@property (nonatomic, strong) NSString *paidOutbrainUrl;
@property (nonatomic, strong) NSDate *loadStartDate;
@property (nonatomic, assign) float percentLoadThreshold;

@end



@implementation CustomWebViewManager

NSString * const kPaidOutbrainPrefix = @"paid.outbrain.com";
NSString * const kReportUrl = @"http://outbrain-node-js.herokuapp.com/api/v1/logs";
int const kReportEventPercentLoad = 100;
int const kReportEventFinished = 200;


+ (id)sharedManager {
    static CustomWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.obRequestQueue = [[NSOperationQueue alloc] init];
        sharedMyManager.percentLoadThreshold = [sharedMyManager paidRecsLoadPercentsThreshold];
    });
    return sharedMyManager;
}


- (void) reportOnProgressAndReportIfNeeded:(float)progress webview:(id)uiwebView_or_wkwebview {
    NSString *urlString = [self getCurrentUrl:uiwebView_or_wkwebview].absoluteString;
    
    if ((progress > self.percentLoadThreshold) &&
        (self.paidOutbrainUrl != nil) &&
        (self.alreadyReportedOnPercentLoad == NO) &&
        ([urlString containsString:kPaidOutbrainPrefix] == NO)) {
        
        NSLog(@"** reportServerOnPercentLoad: %f for: %@ **",progress, urlString);
        
        [self reportServerOnPercentLoad:progress forUrl:[self getCurrentUrl:uiwebView_or_wkwebview].absoluteString orignalPaidOutbrainUrl:self.paidOutbrainUrl loadStartDate:self.loadStartDate]; // we want to report on the percentLoadThreshold to make the heavy BI queries execute faster
        self.alreadyReportedOnPercentLoad = YES;
    }
}

- (void) checkUrlAndReportIfNeeded:(id)uiwebView_or_wkwebview {
    NSURL *currUrl = [self getCurrentUrl:uiwebView_or_wkwebview];
    
    // if its a paid.outbrain URL
    if ([[currUrl absoluteString] containsString:kPaidOutbrainPrefix]) {
        
        // reset parameters
        self.alreadyReportedOnLoadComplete = NO;
        self.alreadyReportedOnPercentLoad = NO;
        
        
        NSArray *components = [[currUrl absoluteString] componentsSeparatedByString:@"?"];
        if (components.count == 2) {
            self.paidOutbrainParams = components[1];
        }
        self.paidOutbrainUrl = [currUrl absoluteString];
        self.loadStartDate = [NSDate date];
        
        return;
    }
    
    if (self.alreadyReportedOnLoadComplete == YES) {
        return;
    }
    
    NSString *tempUrl = [currUrl absoluteString];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.alreadyReportedOnLoadComplete == YES) {
            return;
        }
        
        // Notice this block runs 0.5 seconds after tempUrl is set, this is why the comparison make sence.
        // The webview could change URL in the meantime, especially if the original url was a redirect.
        if ([[[self getCurrentUrl:uiwebView_or_wkwebview] absoluteString] isEqualToString:tempUrl]) {
            
            if (self.paidOutbrainUrl != nil)  {
                NSLog(@"** Real Pageview: %@ **", tempUrl);
                [self reportServerOnPercentLoad:1.0 forUrl:tempUrl orignalPaidOutbrainUrl:self.paidOutbrainUrl loadStartDate:self.loadStartDate];
                
                self.paidOutbrainUrl = nil;
                self.alreadyReportedOnLoadComplete = YES;
            }
        }
        else {
            NSLog(@"NOT Real Pageview: %@ != %@", [[self getCurrentUrl:uiwebView_or_wkwebview] absoluteString], tempUrl);
        }
    });
}

#pragma mark - Reporting to Server

- (void) reportServerOnPercentLoad:(float)percentLoad forUrl:(NSString *)urlString orignalPaidOutbrainUrl:(NSString *)orignalPaidOutbrainUrl loadStartDate:(NSDate *)loadStartDate {
    int eventType = (percentLoad == 1.0) ? kReportEventFinished : kReportEventPercentLoad;
    OBPostOperation *postOperation = [OBPostOperation operationWithURL:[NSURL URLWithString:kReportUrl]];
    postOperation.postData = [self prepareDictionaryForServerReport:eventType percentLoad:(int)(percentLoad*100) url:urlString orignalPaidOutbrainUrl:orignalPaidOutbrainUrl loadStartDate:loadStartDate];
    [self.obRequestQueue addOperation:postOperation];
    NSLog(@"reportServerOnPercentLoad: %@ - %f", urlString, percentLoad);
}


#pragma mark - Private Methods

-(NSURL *) getCurrentUrl:(id)uiwebView_or_wkwebview {
    if ([uiwebView_or_wkwebview isKindOfClass: [UIWebView class]]) {
        UIWebView *webview = (UIWebView *)uiwebView_or_wkwebview;
        return webview.request.URL;
    }
    else if ([uiwebView_or_wkwebview isKindOfClass: [WKWebView class]]) {
        WKWebView *webview = (WKWebView *)uiwebView_or_wkwebview;
        return webview.URL;
    }
    
    return nil;
}

- (NSDictionary *) prepareDictionaryForServerReport:(int)eventType percentLoad:(int)percentLoad url:(NSString *)event_url orignalPaidOutbrainUrl:(NSString *)orignalPaidOutbrainUrl loadStartDate:(NSDate *)loadStartDate {
    // Elapsed Time
    NSDate *timeNow = [NSDate date];
    NSTimeInterval executionTime = [timeNow timeIntervalSinceDate:loadStartDate];
    NSString *elapsedTime = [@((int)(executionTime*1000)) stringValue];
    
    // Partner Key
    SEL selector = NSSelectorFromString(@"partnerKey");
    NSString *partnerKey = [Outbrain performSelector:selector];
    
    //App Version
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [appVersionString stringByReplacingOccurrencesOfString:@" " withString:@""]; // sanity fix
    
    NSDictionary *params = @{@"redirectURL" : orignalPaidOutbrainUrl,
                             @"event_type" : [NSNumber numberWithInt:eventType],
                             @"event_data" : [NSNumber numberWithInt:percentLoad],
                             @"elapsed_time" : elapsedTime,
                             @"event_url" : event_url,
                             @"partner_key" : partnerKey,
                             @"sdk_version" : OB_SDK_VERSION,
                             @"app_ver" : appVersionString,
                             @"network" : [self getNetworkInterface]
                             };
    
    return params;
}


- (NSString *) getNetworkInterface {
    OBReachability *reachability = [OBReachability reachabilityForInternetConnection];
    [reachability startNotifier];
    
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status == ReachableViaWiFi)
    {
        //WiFi
        return @"WiFi";
    }
    else if (status == ReachableViaWWAN)
    {
        //3G
        return @"Mobile Network";
    }
    
    return @"No Internet";
}

#pragma mark - Temp Mocks for server params

- (float) paidRecsLoadPercentsThreshold {
    // TODO should be taken from NSUserDefaults where we save the settings from the ODB server response
    return 0.75;
}


- (BOOL) urlShouldOpenInExternalBrowser {
    return YES;
}

@end
