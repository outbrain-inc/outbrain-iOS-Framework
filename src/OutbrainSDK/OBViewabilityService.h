//
//  OBViewabilityService.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/16/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendationResponse.h"

@interface OBViewabilityService : NSObject


+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSOperationQueue * obRequestQueue;    // Our operation queue

- (void) reportRecsReceived:(OBRecommendationResponse *)response widgetId:(NSString *)widgetId timestamp:(NSDate *)requestStartDate;

- (void) reportRecsShownForWidgetId:(NSString *)widgetId;



@end
