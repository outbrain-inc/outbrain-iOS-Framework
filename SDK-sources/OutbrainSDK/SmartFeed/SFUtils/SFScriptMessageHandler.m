//
//  SFScriptMessageHandler.m
//  OutbrainSDK
//
//  Created by oded regev on 14/10/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFScriptMessageHandler.h"

@interface SFScriptMessageHandler()

@property (nonatomic, weak) id<SFVideoCellType> videoCell;

@end


@implementation SFScriptMessageHandler

- (id)initWithSFVideoCell:(id<SFVideoCellType>)videoCell
{
    self = [super init];
    if(self) {
        self.videoCell = videoCell;
    }
    return self;
}

#pragma mark - WKScriptMessageHandler
-(void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSDictionary *msgBody = message.body;
    SFItemData *sfItem = self.videoCell.sfItem;
    WKWebView *webview = self.videoCell.webview;
    
    NSString *action = msgBody[@"action"];
    if ([@"videoIsReady" isEqualToString:action]) {
        NSLog(@"SFScriptMessageHandler Received: videoIsReady");
        sfItem.videoPlayerStatus = kVideoReadyStatus;
        webview.alpha = 1.0;
    }
    else if ([@"videoFinished" isEqualToString:action]) {
        NSLog(@"SFScriptMessageHandler  Received: videoFinished");
        sfItem.videoPlayerStatus = kVideoFinishedStatus;
        [webview removeFromSuperview];
        self.videoCell.webview = nil;
    }
    else if ([@"pageIsReady" isEqualToString:action]) {
        NSLog(@"SFScriptMessageHandler  Received: pageIsReady");
        NSString * js = [NSString stringWithFormat:@"odbData(%@)", sfItem.videoParamsStr];
        // evaluate js to wkwebview
        [webview evaluateJavaScript:js completionHandler:nil];
    }
    else if ([@"sdkLog" isEqualToString:action]) {
        //NSLog(@"SFScriptMessageHandler  Received: sdkLog");
        //NSLog(@"** Webview sdkLog: %@", message.body);
    }
    else {
        // NSLog(@"** Webview log: %@", message.body);
    }
}

@end
