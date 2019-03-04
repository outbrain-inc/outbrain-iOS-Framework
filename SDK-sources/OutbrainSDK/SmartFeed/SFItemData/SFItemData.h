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


- (id)initWithSingleRecommendation:(OBRecommendation *)rec odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type position:(NSString *)pos;

- (id)initWithList:(NSArray *)recArray odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type positions:(NSArray *)positions;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParamsStr:(NSString *)videoParamsStr singleRecommendation:(OBRecommendation *)rec odbResponse:(OBRecommendationResponse *)odbResponse position:(NSString *)pos;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParamsStr:(NSString *)videoParamsStr reclist:(NSArray *)recArray odbResponse:(OBRecommendationResponse *)odbResponse type:(SFItemType)type positions:(NSArray *)positions;


@property (nonatomic, strong, readonly) NSArray *outbrainRecs;
@property (nonatomic, strong, readonly) OBRecommendation *singleRec;
@property (nonatomic, strong, readonly) OBSettings *odbSettings;
@property (nonatomic, strong, readonly) UIColor *shadowColor;
@property (nonatomic, assign, readonly) SFItemType itemType;
@property (nonatomic, copy, readonly) NSString *widgetTitle;
@property (nonatomic, copy, readonly) NSString *widgetId;
@property (nonatomic, strong, readonly) OBRequest *request;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
@property (nonatomic, copy, readonly) NSString *videoParamsStr;
@property (nonatomic, assign) NSInteger videoPlayerStatus;
@property (nonatomic, assign) BOOL isCustomUI;
@property (nonatomic, copy, readonly) NSString *sourceFormat;
@property (nonatomic, strong, readonly) NSArray *positions;
@property (nonatomic, copy, readonly) NSString *requestId;

+(NSString *) itemTypeString:(SFItemType) type;

@end
