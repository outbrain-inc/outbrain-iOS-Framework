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
@property (nonatomic, assign) BOOL isRTL;
@property (nonatomic, assign) BOOL isSmartFeed;
@property (nonatomic, assign) BOOL isTrendingInCategoryCard;
@property (nonatomic, assign) NSInteger feedCyclesLimit;
@property (nonatomic, assign) NSInteger feedChunkSize;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, copy) NSString *recMode;
@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, copy) NSString *smartfeedShadowColor;
@property (nonatomic, copy) NSString *paidLabelText;
@property (nonatomic, copy) NSString *paidLabelTextColor;
@property (nonatomic, copy) NSString *paidLabelBackgroundColor;
@property (nonatomic, copy) NSString *sourceFormat;

@property (nonatomic, assign) BOOL isViewabilityPerListingEnabled;
@property (nonatomic, assign) NSInteger viewabilityPerListingReportingIntervalMillis;

@end



@implementation OBSettings

- (instancetype)initWithPayload:(NSDictionary *)payload
{
    if (self = [super init]) {
        self.apv = [[payload valueForKey:@"apv"] boolValue];
        self.isRTL = [payload valueForKey:@"dynamicWidgetDirection"] && [[payload valueForKey:@"dynamicWidgetDirection"] isEqualToString:@"RTL"];
        self.isSmartFeed = [[payload valueForKey:@"isSmartFeed"] boolValue];
        self.isTrendingInCategoryCard = [payload valueForKey:@"feedCardType"] && [[payload valueForKey:@"feedCardType"] isEqualToString:@"CONTEXTUAL_TRENDING_IN_CATEGORY"];
        self.feedCyclesLimit = [[payload valueForKey:@"feedCyclesLimit"] integerValue];
        self.feedChunkSize = [[payload valueForKey:@"feedLoadChunkSize"] integerValue];
        self.recMode = [payload valueForKey:@"recMode"];
        self.widgetHeaderText = [payload valueForKey:@"nanoOrganicsHeader"];
        NSString *videoUrlStr = [payload valueForKey:@"sdk_sf_vidget_url"];
        if (videoUrlStr) {
            self.videoUrl = [NSURL URLWithString:videoUrlStr];
        }
        self.smartfeedShadowColor = [payload valueForKey:@"sdk_sf_shadow_color"];
        
        self.paidLabelText = [payload valueForKey:@"dynamic:PaidLabel"];
        self.paidLabelTextColor = [payload valueForKey:@"dynamic:PaidLabelTextColor"];
        self.paidLabelBackgroundColor = [payload valueForKey:@"dynamic:PaidLabelBackgroundColor"];
        
        self.sourceFormat = [payload valueForKey:@"dynamicSourceFormat"];
        
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
        
        self.isViewabilityPerListingEnabled = ![payload valueForKey:@"listingViewability"] || [[payload valueForKey:@"listingViewability"] boolValue];
        self.viewabilityPerListingReportingIntervalMillis = [payload valueForKey:@"listingsViewabilityReportingIntervalMillis"] ? [[payload valueForKey:@"listingsViewabilityReportingIntervalMillis"] intValue] : 2500;
    }
    
    return self;
}

@end
