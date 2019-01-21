//
//  OBSettingsResponse.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 7/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "Outbrain.h"

@interface OBSettings : NSObject

@property (nonatomic, assign, readonly) BOOL apv;
@property (nonatomic, assign, readonly) BOOL isRTL;
@property (nonatomic, assign, readonly) BOOL isSmartFeed;
@property (nonatomic, assign, readonly) NSInteger feedCyclesLimit;
@property (nonatomic, assign, readonly) NSInteger feedChunkSize;
@property (nonatomic, copy, readonly, nullable) NSString *recMode;
@property (nonatomic, copy, readonly, nullable) NSString *widgetHeaderText;
@property (nonatomic, copy, readonly, nullable) NSURL *videoUrl;
@property (nonatomic, copy, readonly, nullable) NSString *smartfeedShadowColor;
@property (nonatomic, strong, readonly, nullable) NSArray *feedContentArray;

@property (nonatomic, copy, readonly, nullable) NSString *paidLabelText;
@property (nonatomic, copy, readonly, nullable) NSString *paidLabelTextColor;
@property (nonatomic, copy, readonly, nullable) NSString *paidLabelBackgroundColor;

@property (nonatomic, copy, readonly, nullable) NSString *sourceFormat;

- (instancetype)initWithPayload:(NSDictionary *)payload;


@end
