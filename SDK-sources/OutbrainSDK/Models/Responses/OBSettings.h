//
//  OBSettingsResponse.h
//  OutbrainSDK
//
//  Created by oded regev on 25/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "Outbrain.h"
#import "OBViewabilityActions.h"
#import "OBBrandedCarouselSettings.h"

@interface OBSettings : NSObject

@property (nonatomic, assign, readonly) BOOL apv;
@property (nonatomic, assign, readonly) BOOL isRTL;
@property (nonatomic, assign, readonly) BOOL isSmartFeed;
@property (nonatomic, assign, readonly) BOOL isTrendingInCategoryCard;
@property (nonatomic, assign, readonly) NSInteger feedCyclesLimit;
@property (nonatomic, assign, readonly) NSInteger feedChunkSize;
@property (nonatomic, copy, readonly, nullable) NSString *recMode;
@property (nonatomic, copy, nullable) NSString *widgetHeaderText;
@property (nonatomic, copy, nullable) NSString *widgetHeaderTextColor;
@property (nonatomic, copy, readonly, nullable) NSURL *videoUrl;
@property (nonatomic, copy, readonly, nullable) NSString *smartfeedShadowColor;
@property (nonatomic, strong, readonly, nullable) NSArray *feedContentArray;

@property (nonatomic, copy, readonly, nullable) NSString *paidLabelText;
@property (nonatomic, copy, readonly, nullable) NSString *paidLabelTextColor;
@property (nonatomic, copy, readonly, nullable) NSString *paidLabelBackgroundColor;

@property (nonatomic, copy, readonly, nullable) NSString *organicSourceFormat;
@property (nonatomic, copy, readonly, nullable) NSString *paidSourceFormat;

@property (nonatomic, assign, readonly) BOOL isViewabilityPerListingEnabled;
@property (nonatomic, assign, readonly) NSInteger viewabilityPerListingReportingIntervalMillis;

@property (nonatomic, copy, readonly, nullable) NSString *readMoreButtonText;

@property (nonatomic, strong, nullable) OBViewabilityActions *viewabilityActions;
@property (nonatomic, strong, nullable) OBBrandedCarouselSettings *brandedCarouselSettings;

@property (nonatomic, assign, readonly) BOOL shouldShowCtaButton;
@property (nonatomic, assign, readonly) NSInteger smartfeedHeaderFontSize;

// AB tests
@property (nonatomic, assign, readonly) NSInteger abTitleFontSize;
@property (nonatomic, assign, readonly) NSInteger abTitleFontStyle; // (Bold (1) or normal (0)
@property (nonatomic, assign, readonly) NSInteger abSourceFontSize;
@property (nonatomic, copy, readonly, nullable) NSString *abSourceFontColor;
@property (nonatomic, assign, readonly) BOOL abImageFadeAnimation;
@property (nonatomic, assign, readonly) NSInteger abImageFadeDuration;


- (instancetype _Nonnull) initWithPayload:(NSDictionary * _Nullable) payload;


@end
