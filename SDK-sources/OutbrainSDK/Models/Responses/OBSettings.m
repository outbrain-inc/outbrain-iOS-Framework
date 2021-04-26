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
@property (nonatomic, assign) BOOL shouldShowCtaButton;
@property (nonatomic, assign) NSInteger smartfeedHeaderFontSize;
@property (nonatomic, assign) NSInteger feedCyclesLimit;
@property (nonatomic, assign) NSInteger feedChunkSize;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, copy) NSString *recMode;
@property (nonatomic, copy) NSURL *videoUrl;
@property (nonatomic, copy) NSString *smartfeedShadowColor;
@property (nonatomic, copy) NSString *paidLabelText;
@property (nonatomic, copy) NSString *paidLabelTextColor;
@property (nonatomic, copy) NSString *paidLabelBackgroundColor;
@property (nonatomic, copy) NSString *readMoreButtonText;
@property (nonatomic, copy) NSString *organicSourceFormat;
@property (nonatomic, copy) NSString *paidSourceFormat;

@property (nonatomic, assign) BOOL isViewabilityPerListingEnabled;
@property (nonatomic, assign) NSInteger viewabilityPerListingReportingIntervalMillis;

// AB tests
@property (nonatomic, assign)   NSInteger abTitleFontSize;
@property (nonatomic, assign)   NSInteger abTitleFontStyle; // (Bold (1) or normal (0)
@property (nonatomic, assign)   NSInteger abSourceFontSize;
@property (nonatomic, copy)     NSString *abSourceFontColor;
@property (nonatomic, assign)   BOOL abImageFadeAnimation;
@property (nonatomic, assign)   NSInteger abImageFadeDuration;

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
        self.widgetHeaderTextColor = [payload valueForKey:@"dynamic:HeaderColor"];
        self.shouldShowCtaButton = [[payload valueForKey:@"dynamic:IsShowButton"] boolValue];
        self.smartfeedHeaderFontSize = [[payload valueForKey:@"dynamic:HeaderFontSize"] integerValue];
        
        // vidget URL
        NSString *vidgetUrlStr = [payload valueForKey:@"sdk_sf_vidget_url"];
        if (vidgetUrlStr && [NSURL URLWithString:vidgetUrlStr]) {
            self.videoUrl = [NSURL URLWithString:vidgetUrlStr];
        }
        else {
            self.videoUrl = [NSURL URLWithString:@"https://libs.outbrain.com/video/app/vidgetInApp.html"];
        }
        
        self.smartfeedShadowColor = [payload valueForKey:@"sdk_sf_shadow_color"];
        
        self.paidLabelText = [payload valueForKey:@"dynamic:PaidLabel"];
        self.paidLabelTextColor = [payload valueForKey:@"dynamic:PaidLabelTextColor"];
        self.paidLabelBackgroundColor = [payload valueForKey:@"dynamic:PaidLabelBackgroundColor"];
        
        self.paidSourceFormat = [payload valueForKey:@"dynamicPaidSourceFormat"];
        self.organicSourceFormat = [payload valueForKey:@"dynamicOrganicSourceFormat"];
        
        self.readMoreButtonText = [payload valueForKey:@"readMoreText"];
        
        // AB tests
        self.abTitleFontSize = [payload valueForKey:@"dynamic:TitleFontSize"] ? [[payload valueForKey:@"dynamic:TitleFontSize"] integerValue] : 0;
        self.abSourceFontSize = [payload valueForKey:@"dynamic:SourceFontSize"] ? [[payload valueForKey:@"dynamic:SourceFontSize"] integerValue] : 0;
        self.abTitleFontStyle = [payload valueForKey:@"dynamic:TitleTextStyle"] ? [[payload valueForKey:@"dynamic:TitleTextStyle"] integerValue] : 0;
        self.abSourceFontColor = [payload valueForKey:@"dynamic:SourceColor"];
        self.abImageFadeDuration = [payload valueForKey:@"imgFadeDur"] ? [[payload valueForKey:@"imgFadeDur"] integerValue] : 500;
        self.abImageFadeAnimation = [payload valueForKey:@"imgFade"] ? [[payload valueForKey:@"imgFade"] boolValue] : YES;
        
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
