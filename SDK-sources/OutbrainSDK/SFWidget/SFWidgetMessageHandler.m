//
//  SFWidgetMessageHandler.m
//  OutbrainSDK
//
//  Created by Oded Regev on 27/06/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import "SFWidgetMessageHandler.h"
#import "SFWidget.h"

@implementation SFWidgetMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    @try  {
        if (! [message.name isEqualToString:@"ReactNativeWebView"]) {
            NSLog(@"SFWidgetMessageHandler - message is not ReactNativeWebView");
            return;
        }
        NSString *jsonString = message.body;
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *msgBody = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        
        
        if ([msgBody valueForKey:@"height"]) {
            NSInteger newHeight = [[msgBody valueForKey:@"height"] integerValue];
            [self.delegate didHeightChanged:newHeight];
        }
        if ([msgBody valueForKey:@"t"]) {
            NSString *tParam = [msgBody valueForKey:@"t"];
            NSLog(@"SFWidgetMessageHandler received t param: %@", tParam);
            [[NSNotificationCenter defaultCenter] postNotificationName:SFWIDGET_T_PARAM_NOTIFICATION object:self userInfo:@{@"t" : tParam}];
        }
        if ([msgBody valueForKey:@"url"]) {
            NSString *urlString = [msgBody valueForKey:@"url"];
            NSString *type = [msgBody valueForKey:@"type"];
            if ([type isEqualToString:@"organic-rec"]) {
                NSString *orgUrl = [msgBody valueForKey:@"orgUrl"];
                [self.delegate didClickOnOrganicRec:urlString orgUrl:orgUrl];
            }
            else {
                [self.delegate didClickOnRec:urlString];
            }
        }
    } @catch (NSException *exception) {
      NSLog(@"Exception in SFWidgetMessageHandler() - %@ ",exception.name);
      NSLog(@"Reason: %@ ",exception.reason);
    }
}

@end
