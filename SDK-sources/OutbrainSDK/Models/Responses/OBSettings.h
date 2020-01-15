//
//  OBSettingsResponse.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 7/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "Outbrain.h"
#import "OBViewabilityActions.h"

@interface OBSettings : NSObject

@property (nonatomic, assign, readonly) BOOL apv;
@property (nonatomic, assign, readonly) BOOL isRTL;
@property (nonatomic, assign, readonly) BOOL isSmartFeed;
@property (nonatomic, assign, readonly) BOOL isTrendingInCategoryCard;
@property (nonatomic, assign, readonly) NSInteger feedCyclesLimit;
@property (nonatomic, assign, readonly) NSInteger feedChunkSize;
@property (nonatomic, copy, readonly, nullable) NSString *recMode;
@property (nonatomic, copy, nullable) NSString *widgetHeaderText;
@property (nonatomic, copy, readonly, nullable) NSURL *videoUrl;
@property (nonatomic, copy, readonly, nullable) NSString *smartfeedShadowColor;
@property (nonatomic, strong, readonly, nullable) NSArray *feedContentArray;

@property (nonatomic, copy, readonly, nullable) NSString *paidLabelText;
@property (nonatomic, copy, readonly, nullable) NSString *paidLabelTextColor;
@property (nonatomic, copy, readonly, nullable) NSString *paidLabelBackgroundColor;

@property (nonatomic, copy, readonly, nullable) NSString *sourceFormat;

@property (nonatomic, assign, readonly) BOOL isViewabilityPerListingEnabled;
@property (nonatomic, assign, readonly) NSInteger viewabilityPerListingReportingIntervalMillis;

@property (nonatomic, strong, nullable) OBViewabilityActions *viewabilityActions;

- (instancetype _Nonnull) initWithPayload:(NSDictionary * _Nullable) payload;


@end
