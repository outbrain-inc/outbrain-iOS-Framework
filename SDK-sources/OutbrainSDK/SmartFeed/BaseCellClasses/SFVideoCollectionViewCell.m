//
//  SFVideoCollectionViewCell.m
//  OutbrainSDK
//
//  Created by oded regev on 12/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFVideoCollectionViewCell.h"
#import "SFItemData.h"

@interface SFVideoCollectionViewCell() 

@end

@implementation SFVideoCollectionViewCell

#pragma mark - WKScriptMessageHandler
-(void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *msgBody = message.body;
    NSString *action = msgBody[@"action"];
    if ([@"videoIsReady" isEqualToString:action]) {
        NSLog(@"SFVideoCollectionViewCell Received: videoIsReady");
        self.sfItem.videoPlayerStatus = kVideoReadyStatus;
        self.webview.alpha = 1.0;
        [self.spinner stopAnimating];
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"VideoReadyNotification"
         object:self];
    }
    else if ([@"videoFinished" isEqualToString:action]) {
        NSLog(@"SFVideoCollectionViewCell  Received: videoFinished");
        self.sfItem.videoPlayerStatus = kVideoFinishedStatus;
    }
}

@end
