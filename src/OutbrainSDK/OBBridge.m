//
//  OBBridge.m
//  OutbrainSDK
//
//  Created by Oded Regev on 7/4/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBBridge.h"
#import "OutbrainHelper.h"
#import "Outbrain.h"


@implementation OBBridge

#pragma mark - Custom OBWebView
+ (BOOL) isOutbrainPaidUrl:(NSURL *)url {
    NSString *currentUrl = [url absoluteString];
    return [currentUrl containsString:@"paid.outbrain.com/network/redir"];
}

+ (BOOL) shouldOpenInSafariViewController:(NSURL *)url {
    NSString *currentUrl = [url absoluteString];
    return [currentUrl containsString:@"cwvShouldOpenInExternalBrowser=true"];
}

+ (BOOL) registerOutbrainResponse:(NSDictionary *)jsonDictionary {
    if (jsonDictionary[@"response"][@"documents"][@"doc"] == nil) {
        return NO;
    }
    
    [[OutbrainHelper sharedInstance] updateCustomWebViewSettings:jsonDictionary[@"response"][@"settings"]];
    
    return YES;
}

#pragma mark - Initilize Outbrain
+ (void)initializeOutbrainWithPartnerKey:(NSString *)partnerKey {
    [Outbrain initializeOutbrainWithPartnerKey:partnerKey];
}

@end
