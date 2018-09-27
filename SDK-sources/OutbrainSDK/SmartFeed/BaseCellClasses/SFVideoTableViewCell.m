//
//  SFVideoTableViewCell.m
//  OutbrainSDK
//
//  Created by oded regev on 25/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFVideoTableViewCell.h"
#import "SFItemData.h"

@implementation SFVideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

#pragma mark - WKScriptMessageHandler
-(void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *msgBody = message.body;
    NSString *action = msgBody[@"action"];
    if ([@"videoIsReady" isEqualToString:action]) {
        NSLog(@"SFVideoTableViewCell Received: videoIsReady");
        self.sfItem.videoPlayerStatus = kVideoReadyStatus;
        self.webview.alpha = 1.0;
        [self.spinner stopAnimating];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"VideoReadyNotification"
         object:self];
    }
    else if ([@"videoFinished" isEqualToString:action]) {
        NSLog(@"SFVideoTableViewCell  Received: videoFinished");
        self.sfItem.videoPlayerStatus = kVideoFinishedStatus;
    }
    else if ([@"pageIsReady" isEqualToString:action]) {
        NSLog(@"SFVideoTableViewCell  Received: pageIsReady");
        NSString * js = [NSString stringWithFormat:@"odbData(%@)", self.sfItem.videoParamsStr];
        // evaluate js to wkwebview
        NSLog(@"pageIsReady -> %@", js);
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
