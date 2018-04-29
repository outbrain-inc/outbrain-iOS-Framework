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
@property (nonatomic, strong) NSArray *feedContentArray;


@end



@implementation OBSettings

- (instancetype)initWithPayload:(NSDictionary *)payload
{
    if (self = [super init]) {
        self.apv = [[payload valueForKey:@"apv"] boolValue];
        self.isSmartFeed = [[payload valueForKey:@"isSmartFeed"] boolValue];
        NSString *feedContentStr = [payload valueForKey:@"feedContent"];
        if (self.isSmartFeed && feedContentStr != nil) {
            NSData *feedContentData = [feedContentStr dataUsingEncoding:NSUTF8StringEncoding];
            self.feedContentArray = [NSJSONSerialization JSONObjectWithData:feedContentData options:0 error:nil];
        }
    }
    
    return self;
}

@end
