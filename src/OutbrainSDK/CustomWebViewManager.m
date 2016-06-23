//
//  CustomWebViewManager.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/23/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "CustomWebViewManager.h"
#import "OBReachability.h"
#import "OBPostOperation.h"
#import "Outbrain.h"

@interface CustomWebViewManager()
@property (nonatomic, strong) NSOperationQueue * obRequestQueue;    // Our operation queue
@end



@implementation CustomWebViewManager

NSString * const kReportUrl = @"http://outbrain-node-js.herokuapp.com/api/v1/logs";
int const kReportEventPercentLoad = 100;
int const kReportEventFinished = 200;


+ (id)sharedManager {
    static CustomWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.obRequestQueue = [[NSOperationQueue alloc] init];
    });
    return sharedMyManager;
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
