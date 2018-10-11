//
//  SFHorizontalCell.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalWithVideoCollectionViewCell.h"
#import "SFUtils.h"

@implementation SFHorizontalWithVideoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
-(void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *msgBody = message.body;
    NSString *action = msgBody[@"action"];
    if ([@"videoIsReady" isEqualToString:action]) {
        NSLog(@"SFVideoCollectionViewCell Received: videoIsReady");
        self.sfItem.videoPlayerStatus = kVideoReadyStatus;
        self.webview.alpha = 1.0;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"VideoReadyNotification"
         object:self];
    }
    else if ([@"videoFinished" isEqualToString:action]) {
        NSLog(@"SFVideoCollectionViewCell  Received: videoFinished");
        self.sfItem.videoPlayerStatus = kVideoFinishedStatus;
        [self.webview removeFromSuperview];
        self.webview = nil;
    }
    else if ([@"pageIsReady" isEqualToString:action]) {
        NSLog(@"SFVideoTableViewCell  Received: pageIsReady");
        NSString * js = [NSString stringWithFormat:@"odbData(%@)", self.sfItem.videoParamsStr];
        // evaluate js to wkwebview
        [self.webview evaluateJavaScript:js completionHandler:nil];
    }
    else if ([@"sdkLog" isEqualToString:action]) {
        NSLog(@"SFVideoTableViewCell  Received: sdkLog");
        NSLog(@"** Webview sdkLog: %@", message.body);
    }
    else {
        NSLog(@"** Webview log: %@", message.body);
    }
}

@end
