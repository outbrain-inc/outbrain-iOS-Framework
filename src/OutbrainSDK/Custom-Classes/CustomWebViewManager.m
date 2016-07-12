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
#import "OutbrainHelper.h"


@interface CustomWebViewManager()

@property (nonatomic, strong) NSOperationQueue * obRequestQueue;    // Our operation queue

@property (nonatomic, assign) BOOL alreadyReportedOnPercentLoad;
@property (nonatomic, assign) BOOL alreadyReportedOnLoadComplete;

@property (nonatomic, strong) NSString *paidOutbrainUrl;
@property (nonatomic, strong) NSDate *loadStartDate;
@property (nonatomic, assign) float percentLoadThreshold;


- (BOOL) isCustomWebViewReportingEnabled;
- (float) customWebViewThreshold;

- (void) reportServerOnPercentLoad:(float)percentLoad forUrl:(NSString *)urlString orignalPaidOutbrainUrl:(NSString *)orignalPaidOutbrainUrl loadStartDate:(NSDate *)loadStartDate;

@end



@implementation CustomWebViewManager

NSString * const kCustomWebViewReportingEnabledKey = @"kCustomWebViewReportingEnabledKey";
NSString * const kCustomWebViewThresholdKey = @"kCustomWebViewThreshold";

NSString * const kPaidOutbrainPrefix = @"paid.outbrain.com";
NSString * const kReportUrl = @"http://eventlog.outbrain.com/logger/v1/mobile";
int const kReportEventPercentLoad = 100;
int const kReportEventFinished = 200;


+ (id)sharedManager {
    static CustomWebViewManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        sharedMyManager.obRequestQueue = [[NSOperationQueue alloc] init];
        sharedMyManager.percentLoadThreshold = [sharedMyManager customWebViewThreshold];
    });
    return sharedMyManager;
}


- (void) reportOnProgressAndReportIfNeeded:(float)progress webview:(id)uiwebView_or_wkwebview {
    NSString *urlString = [self getCurrentUrl:uiwebView_or_wkwebview].absoluteString;
    
    if ((progress > self.percentLoadThreshold) &&
        (self.paidOutbrainUrl != nil) &&
        (self.alreadyReportedOnPercentLoad == NO) &&
        ([urlString containsString:kPaidOutbrainPrefix] == NO)) {
        
        [self reportServerOnPercentLoad:progress forUrl:urlString orignalPaidOutbrainUrl:self.paidOutbrainUrl loadStartDate:self.loadStartDate];
        self.alreadyReportedOnPercentLoad = YES;
    }
}

- (void) checkUrlAndReportIfNeeded:(id)uiwebView_or_wkwebview {
    NSURL *currUrl = [self getCurrentUrl:uiwebView_or_wkwebview];
    NSString *currUrlString = [currUrl absoluteString];
    
    // if its a paid.outbrain URL
    if ([currUrlString containsString:kPaidOutbrainPrefix] &&
        [currUrlString containsString:kCWV_CONTEXT_FLAG]) {
        
        // reset parameters
        self.alreadyReportedOnLoadComplete = NO;
        self.alreadyReportedOnPercentLoad = NO;
        
        self.paidOutbrainUrl = [currUrl absoluteString];
        self.loadStartDate = [NSDate date];
        
        // Support JS Widget Settings parsing here
        if ([currUrlString containsString:@"cwvContext=app_js_widget"]) {
            [self parseOdbSettingsFromPaidOutbrainUrl:currUrlString];
        }
        
        return;
    }
    
    
    if (self.alreadyReportedOnLoadComplete == YES) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (self.alreadyReportedOnLoadComplete == YES) {
            return;
        }
        
        // Notice this block runs 0.5 seconds after currUrlString is set, this is why the comparison make sense.
        // The webview could change URL in the meantime, especially if the original url was a redirect.
        if ([[[self getCurrentUrl:uiwebView_or_wkwebview] absoluteString] isEqualToString:currUrlString]) {
            
            if (self.paidOutbrainUrl != nil)  {
                NSLog(@"** Real Pageview: %@ **", currUrlString);
                [self reportServerOnPercentLoad:1.0 forUrl:currUrlString orignalPaidOutbrainUrl:self.paidOutbrainUrl loadStartDate:self.loadStartDate];
                
                self.paidOutbrainUrl = nil;
                self.alreadyReportedOnLoadComplete = YES;
            }
        }
        else {
            // NSLog(@"NOT Real Pageview: %@ != %@", [[self getCurrentUrl:uiwebView_or_wkwebview] absoluteString], currUrlString);
        }
    });
}

#pragma mark - Reporting to Server

- (void) reportServerOnPercentLoad:(float)percentLoad forUrl:(NSString *)urlString orignalPaidOutbrainUrl:(NSString *)orignalPaidOutbrainUrl loadStartDate:(NSDate *)loadStartDate {
    
    if ([self isCustomWebViewReportingEnabled] == NO) {
        return;
    }
    
    NSLog(@"** reportServerOnPercentLoad: %f for: %@ **",percentLoad, urlString);
    
    int eventType = (percentLoad == 1.0) ? kReportEventFinished : kReportEventPercentLoad;
    OBPostOperation *postOperation = [OBPostOperation operationWithURL:[NSURL URLWithString:kReportUrl]];
    postOperation.postData = [self prepareDictionaryForServerReport:eventType percentLoad:(int)(percentLoad*100) url:urlString orignalPaidOutbrainUrl:orignalPaidOutbrainUrl loadStartDate:loadStartDate];
    [self.obRequestQueue addOperation:postOperation];
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
    NSString *partnerKey = [[OutbrainHelper sharedInstance] partnerKey];
    
    //App Version
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [appVersionString stringByReplacingOccurrencesOfString:@" " withString:@""]; // sanity fix
    
    if (!orignalPaidOutbrainUrl || !event_url || !partnerKey ) { // sanity
        return nil;
    }
    
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

#pragma mark - Custom WebView Settings

// paidUrl is a JS Widget paid.outbrain Url With ODB Settings after #
- (void) parseOdbSettingsFromPaidOutbrainUrl:(NSString *)paidUrl {
    NSArray *components = [paidUrl componentsSeparatedByString:@"#"];
    if (components.count != 2) {
        NSLog(@"Outbrain - error in parseOdbSettingsFromPaidOutbrainUrl()");
        return;
    }
    
    NSString *settingsParams = components[1];
    NSMutableDictionary *settingsDictionary = [[NSMutableDictionary alloc] init];
    NSArray *urlComponents = [settingsParams componentsSeparatedByString:@"&"];
    
    // Populate settingsDictionary with the key\value params
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [settingsDictionary setObject:value forKey:key];
    }
    
    [[OutbrainHelper sharedInstance] updateCustomWebViewSettings: settingsDictionary];
}

- (void) updateCWVSetting:(NSNumber *)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    
    self.percentLoadThreshold = [self customWebViewThreshold];
}

- (BOOL) isCustomWebViewReportingEnabled {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCustomWebViewReportingEnabledKey]) {
        NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomWebViewReportingEnabledKey];
        return [val boolValue];
    }
    return YES;
}

- (float) customWebViewThreshold {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kCustomWebViewThresholdKey]) {
        NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomWebViewThresholdKey];
        return [val floatValue] / 100.0;
    }
    return 0.8;
}

@end
