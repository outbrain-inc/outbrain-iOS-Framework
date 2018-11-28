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

@interface SFItemData : NSObject

extern NSInteger kVideoInitStatus;
extern NSInteger kVideoReadyStatus;
extern NSInteger kVideoFinishedStatus;


- (id)initWithSingleRecommendation:(OBRecommendation *)rec type:(SFItemType)type widgetTitle:(NSString *)widgetTitle request:(OBRequest *)request shadowColorStr:(NSString *)shadowColorStr;

- (id)initWithList:(NSArray *)recArray type:(SFItemType)type widgetTitle:(NSString *)widgetTitle request:(OBRequest *)request shadowColorStr:(NSString *)shadowColorStr;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams singleRecommendation:(OBRecommendation *)rec widgetTitle:(NSString *)widgetTitle request:(OBRequest *)request shadowColorStr:(NSString *)shadowColorStr;

- (id)initWithVideoUrl:(NSURL *)videoUrl videoParams:(NSDictionary *)videoParams reclist:(NSArray *)recArray type:(SFItemType)type widgetTitle:(NSString *)widgetTitle request:(OBRequest *)request shadowColorStr:(NSString *)shadowColorStr;

@property (nonatomic, strong, readonly) NSArray *outbrainRecs;
@property (nonatomic, strong, readonly) OBRecommendation *singleRec;
@property (nonatomic, strong, readonly) UIColor *shadowColor;
@property (nonatomic, assign, readonly) SFItemType itemType;
@property (nonatomic, copy, readonly) NSString *widgetTitle;
@property (nonatomic, copy, readonly) NSString *widgetId;
@property (nonatomic, strong, readonly) OBRequest *request;
@property (nonatomic, strong, readonly) NSURL *videoUrl;
@property (nonatomic, copy, readonly) NSString *videoParamsStr;
@property (nonatomic, assign) NSInteger videoPlayerStatus;
@property (nonatomic, assign) BOOL isCustomUI;

+(NSString *) itemTypeString:(SFItemType) type;

@end
