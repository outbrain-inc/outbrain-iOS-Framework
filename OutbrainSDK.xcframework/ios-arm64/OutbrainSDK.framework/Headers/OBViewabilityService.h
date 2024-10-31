//
//  OBViewabilityService.h
//  OutbrainSDK
//
//  Created by Oded Regev on 11/16/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendationResponse.h"

@interface OBViewabilityService : NSObject

+ (instancetype)sharedInstance;

- (void) addOBLabelToMap:(OBLabel *)obLabel;

- (void) reportRecsReceived:(OBRecommendationResponse *)response timestamp:(NSDate *)requestStartDate;

- (void) reportRecsShownForOBLabel:(OBLabel *)obLabel;

- (void) reportRecsShownForRequestId:(NSString *)reqId;

- (void) updateViewabilitySetting:(NSNumber *)value key:(NSString *)key;

- (BOOL) isViewabilityEnabled;

- (int) viewabilityThresholdMilliseconds;

-(NSDate *) initializationTimeForReqId:(NSString *)reqId;

extern NSString * const kViewabilityEnabledKey;
extern NSString * const kViewabilityThresholdKey;

@end
