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


@implementation OBErrorReporting


NSString * const kReportErrorUrl = @"https://widgetmonitor.outbrain.com/WidgetErrorMonitor/api/report";

+ (instancetype)sharedInstance
{
    static OBErrorReporting *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OBErrorReporting alloc] init];
    });
    
    return sharedInstance;
}

- (NSURL *) erroReportURLForMessage:(NSString *)errorMessage {
    NSMutableArray *odbQueryItems = [[NSMutableArray alloc] init];
    NSURLComponents *components = [NSURLComponents componentsWithString: kReportErrorUrl];
    
    NSString *partnerKey = [OutbrainManager sharedInstance].partnerKey;
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"partnerKey" value: (partnerKey ? partnerKey : @"(null)")]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"message" value: (errorMessage ? errorMessage : @"(null)")]];
    components.queryItems = odbQueryItems;
    NSLog(@"URL: %@", components.URL);
    
    return components.URL;
}

- (void) reportErrorToServer:(NSString *)errorMessage {
    NSURL *url = [self erroReportURLForMessage:errorMessage];
    
    [[OBNetworkManager sharedManager] sendGet:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            NSLog(@"Error OBErrorReporting - reportErrorToServer - %@", error);
        }
    }];
}

@end
