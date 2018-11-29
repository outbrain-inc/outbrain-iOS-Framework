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

@interface SFItemData : NSObject

extern NSInteger kVideoInitStatus;
extern NSInteger kVideoReadyStatus;
extern NSInteger kVideoFinishedStatus;


- (id)initWithSingleRecommendation:(OBRecommendation *)rec odbSettings:(OBSettings *)odbSettings type:(SFItemType)type widgetId:(NSString *)widgetId;

- (id)initWithList:(NSArray *)recArray odbSettings:(OBSettings *)odbSettings type:(SFItemType)type widgetId:(NSString *)widgetId;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams singleRecommendation:(OBRecommendation *)rec odbSettings:(OBSettings *)odbSettings widgetId:(NSString *)widgetId;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams reclist:(NSArray *)recArray odbSettings:(OBSettings *)odbSettings type:(SFItemType)type widgetId:(NSString *)widgetId;

@property (nonatomic, strong, readonly) NSArray *outbrainRecs;
@property (nonatomic, strong, readonly) OBRecommendation *singleRec;
@property (nonatomic, strong, readonly) OBSettings *odbSettings;
@property (nonatomic, strong, readonly) UIColor *shadowColor;
@property (nonatomic, assign, readonly) SFItemType itemType;
@property (nonatomic, copy, readonly) NSString *widgetTitle;
@property (nonatomic, copy, readonly) NSString *widgetId;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
@property (nonatomic, copy, readonly) NSString *videoParamsStr;
@property (nonatomic, assign) NSInteger videoPlayerStatus;
@property (nonatomic, assign) BOOL isCustomUI;

+(NSString *) itemTypeString:(SFItemType) type;

@end
