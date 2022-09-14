//
//  SFWidgetMessageHandler.m
//  OutbrainSDK
//
//  Created by Oded Regev on 27/06/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import "SFWidgetMessageHandler.h"
#import "SFWidget.h"
#import "OBErrorReporting.h"

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
        
        // Oded start
//        if ([msgBody valueForKey:@"t"]) {
//            msgBody = @{@"event" : @{@"idx": @2, @"widgetId": @"MB_22", @"name": @"viewability", @"timestamp" : @"1662616918768"}};
//        }
        // Oded end
        
        if ([msgBody valueForKey:@"height"]) {
            NSLog(@"HEIGHT - msgBody: %@", msgBody);
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
        if ([msgBody valueForKey:@"event"] && ([[msgBody valueForKey:@"event"] isKindOfClass:[NSDictionary class]])) {
            NSMutableDictionary *eventData = [[msgBody valueForKey:@"event"] mutableCopy];
            NSString *eventName = @"";
            if ([[eventData valueForKey:@"name"] isKindOfClass:[NSString class]]) {
                eventName = [eventData valueForKey:@"name"];
            }
            else {
                eventName = @"** event_name_missing **";
            }
            [eventData removeObjectForKey:@"name"];
            
            BOOL eventDataKeysAreValid = YES; // initial value
            NSEnumerator *keyEnumerator = [eventData keyEnumerator];
            id key;
            while ((key = [keyEnumerator nextObject])) {
                if (![key isKindOfClass:[NSString class]]) {
                    NSLog(@"OBSDK The key (%@) does not belong to NSString class", key);
                    eventDataKeysAreValid = NO;
                    break;
                }
            }
            if (eventDataKeysAreValid) {
                [self.delegate widgetEvent:eventName additionalData:eventData];
            }
        }
        if ([msgBody valueForKey:@"errorMsg"]) {
            NSString *errorMsg = [msgBody valueForKey:@"errorMsg"];
            errorMsg = [NSString stringWithFormat:@"Bridge: %@", errorMsg];
            [[OBErrorReporting sharedInstance] reportErrorToServer:errorMsg];
        }
        
    } @catch (NSException *exception) {
        NSLog(@"Exception in SFWidgetMessageHandler() - %@",exception.name);
        NSLog(@"Reason: %@ ",exception.reason);
        NSString *errorMsg = [NSString stringWithFormat:@"Exception in SFWidgetMessageHandler - %@ - reason: %@", exception.name, exception.reason];
        [[OBErrorReporting sharedInstance] reportErrorToServer:errorMsg];
    }
}

@end
