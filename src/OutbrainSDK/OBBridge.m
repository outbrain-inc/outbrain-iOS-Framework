//
//  OBBridge.m
//  OutbrainSDK
//
//  Created by Oded Regev on 7/4/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import "OBBridge.h"

@implementation OBBridge

#pragma mark - Custom OBWebView
+ (BOOL) isOutbrainPaidUrl:(NSURL *)url {
    NSString *currentUrl = [url absoluteString];
    return [currentUrl containsString:@"paid.outbrain.com/network/redir"];
}

+ (BOOL) shouldOpenUrlInSafariViewController:(NSURL *)url {
    return NO;
}

@end
