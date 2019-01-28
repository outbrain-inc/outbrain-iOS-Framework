//
//  SFScriptMessageHandler.m
//  OutbrainSDK
//
//  Created by oded regev on 14/10/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFScriptMessageHandler.h"
#import "SFUtils.h"

@interface SFScriptMessageHandler()

@property (nonatomic, weak) id<SFVideoCellType> videoCell;

@end


@implementation SFScriptMessageHandler

- (id)initWithSFVideoCell:(id<SFVideoCellType>)videoCell
{
    self = [super init];
    if(self) {
        self.videoCell = videoCell;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveVideoPauseNotification:)
                                                     name:OB_VIDEO_PAUSE_NOTIFICATION
                                                   object:nil];
    }
    return self;
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - NSNotificationCenter
- (void) receiveVideoPauseNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    
    if ([[notification name] isEqualToString: OB_VIDEO_PAUSE_NOTIFICATION]) {
        if (!self.videoCell.webview) {
            return;
        }
        NSString* js = @"systemVideoPause()";
        [self.videoCell.webview evaluateJavaScript:js completionHandler:nil];
    }
}


@end
