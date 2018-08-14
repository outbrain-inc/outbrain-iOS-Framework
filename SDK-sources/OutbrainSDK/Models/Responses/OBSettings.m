//
//  OBSettingsResponse.m
//  OutbrainSDK
//
//  Created by Oded Regev on 7/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBSettings.h"


@interface OBSettings()

@property (nonatomic, assign) BOOL apv;
@property (nonatomic, assign) BOOL isSmartFeed;
@property (nonatomic, assign) NSInteger feedCyclesLimit;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, copy) NSString *recMode;
@property (nonatomic, copy) NSString *widgetHeaderText;


@end



@implementation OBSettings

- (instancetype)initWithPayload:(NSDictionary *)payload
{
    if (self = [super init]) {
        self.apv = [[payload valueForKey:@"apv"] boolValue];
        self.isSmartFeed = [[payload valueForKey:@"isSmartFeed"] boolValue];
        self.feedCyclesLimit = [[payload valueForKey:@"feedCyclesLimit"] integerValue];
        self.recMode = [payload valueForKey:@"recMode"];
        self.widgetHeaderText = [payload valueForKey:@"nanoOrganicsHeader"];
        NSString *feedContentStr = [payload valueForKey:@"feedContent"];
        if (self.isSmartFeed && feedContentStr != nil) {
            NSData *feedContentData = [feedContentStr dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *originalFeedContentArray = [NSJSONSerialization JSONObjectWithData:feedContentData options:0 error:nil];
            NSMutableArray *feedItemsArr = [[NSMutableArray alloc] init];
            for (NSDictionary *item in originalFeedContentArray) {
                [feedItemsArr addObject:[item valueForKey:@"id"]];
            }
            self.feedContentArray = [feedItemsArr copy];
        }
    }
    
    return self;
}

@end
