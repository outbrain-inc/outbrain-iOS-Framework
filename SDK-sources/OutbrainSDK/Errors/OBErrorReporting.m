//
//  OBErrorReporting.m
//  OutbrainSDK
//
//  Created by Oded Regev on 28/04/2022.
//  Copyright © 2022 Outbrain. All rights reserved.
//

#import "OBErrorReporting.h"
#import "OutbrainManager.h"
#import "OBNetworkManager.h"
#import "OBUtils.h"

@implementation OBErrorReporting


NSString * const kReportErrorUrl = @"https://widgetmonitor.outbrain.com/WidgetErrorMonitor/api/report";
NSString * const kSDK_ERROR_REPORT_NAME = @"TEST_IOS_SDK_ERROR";

+ (instancetype)sharedInstance
{
    static OBErrorReporting *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OBErrorReporting alloc] init];
    });
    
    return sharedInstance;
}

- (NSURL *) errorReportURLForMessage:(NSString *)errorMessage {
    NSMutableArray *odbQueryItems = [[NSMutableArray alloc] init];
    NSURLComponents *components = [NSURLComponents componentsWithString: kReportErrorUrl];
    
    // Event Name for SDK error
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"name" value: kSDK_ERROR_REPORT_NAME]];
    
    // Partner Key
    NSString *partnerKey = [OutbrainManager sharedInstance].partnerKey;
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"partnerKey" value: (partnerKey ? partnerKey : @"(null)")]];
    
    // SDK Version
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"version" value: OB_SDK_VERSION]];
    
    //Device model
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dm" value: [OBUtils deviceModel]]];
    
    //App Version
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    appVersionString = [appVersionString stringByReplacingOccurrencesOfString:@" " withString:@""]; // sanity fix
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"app_ver" value: appVersionString]];
    
    //OS version
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"dosv" value: [[UIDevice currentDevice] systemVersion]]];
    
    //Random
    NSInteger randInteger = (arc4random() % 10000);
    NSString *randNumStr = [NSString stringWithFormat:@"%li", (long)randInteger];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"rand" value: randNumStr]];
    
    // SID, PID, URL
    if (self.odbRequestUrlParamValue) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"url" value: self.odbRequestUrlParamValue]];
    }
    if (self.sourceId) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"sId" value: self.sourceId]];
    }
    if (self.publisherId) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"pId" value: self.publisherId]];
    }
    
    // Error Message
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"message" value: (errorMessage ? errorMessage : @"(null)")]];
    components.queryItems = odbQueryItems;
    NSLog(@"URL: %@", components.URL);
    
    return components.URL;
}

// Example
/*
 https://widgetmonitor.outbrain.com/WidgetErrorMonitor/api/report?name=IOS_SDK_ERROR&version=ODED_SDK_VERSION&message=ODED_EVENT_MESSAGE&url=ODED_PUBLISHER_URL&referrer=&agent=mozilla/5.0 (iphone; cpu iphone os 13_2_3 like mac os x) applewebkit/605.1.15 (khtml, like gecko) version/13.0.3 mobile/15e148 safari/604.1&stack=undefined&errorEleUrl=&pId=4623&sId=8106322&dId=4361794921'
 */
- (void) reportErrorToServer:(NSString *)errorMessage {
    NSURL *url = [self errorReportURLForMessage:errorMessage];
    
    [[OBNetworkManager sharedManager] sendGet:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error OBErrorReporting - reportErrorToServer - %@", error);
        }
    }];
}

@end
