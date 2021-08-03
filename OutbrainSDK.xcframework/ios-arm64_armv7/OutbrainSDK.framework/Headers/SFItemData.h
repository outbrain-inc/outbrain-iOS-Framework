//
//  SFItemData.h
//  OutbrainSDK
//
//  Created by oded regev on 23/04/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendation.h"
#import "SmartFeedManager.h"
#import "OBRequest.h"
#import "OBRecommendationResponse.h"
#import "OBSettings.h"

@interface SFItemData : NSObject

extern NSInteger kVideoInitStatus;
extern NSInteger kVideoReadyStatus;
extern NSInteger kVideoFinishedStatus;


- (id)initWithSingleRecommendation:(OBRecommendation *)rec odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type;

- (id)initWithList:(NSArray *)recArray odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParamsStr:(NSString *)videoParamsStr singleRecommendation:(OBRecommendation *)rec odbResponse:(OBRecommendationResponse *)odbResponse;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParamsStr:(NSString *)videoParamsStr reclist:(NSArray *)recArray odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type;


@property (nonatomic, strong, readonly) NSArray *outbrainRecs;
@property (nonatomic, strong, readonly) OBRecommendation *singleRec;
@property (nonatomic, strong, readonly) OBSettings *odbSettings;
@property (nonatomic, strong, readonly) UIColor *shadowColor;
@property (nonatomic, assign, readonly) SFItemType itemType;
@property (nonatomic, copy, readonly) NSString *widgetTitle;
@property (nonatomic, strong, readonly) UIColor *widgetTitleTextColor;
@property (nonatomic, copy, readonly) NSString *widgetId;
@property (nonatomic, copy, readonly) NSString *abTestVal;
@property (nonatomic, strong, readonly) OBRequest *request;
@property (nonatomic, strong, readonly) OBResponseRequest *responseRequest;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
@property (nonatomic, copy, readonly) NSString *videoParamsStr;
@property (nonatomic, assign) NSInteger videoPlayerStatus;
@property (nonatomic, assign) BOOL isCustomUI;
@property (nonatomic, strong, readonly) NSMutableArray *positions;
@property (nonatomic, copy, readonly) NSString *requestId;
@property (nonatomic, assign, readonly) BOOL isLastInWidget; // applies for single rec only

+(NSString *) itemTypeString:(SFItemType) type;

@end
