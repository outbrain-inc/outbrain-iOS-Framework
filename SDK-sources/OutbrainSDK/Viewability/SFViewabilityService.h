//
//  SFViewabilityService.h
//  OutbrainSDK
//
//  Created by Alon Shprung on 2/28/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBView.h"
#import "SFItemData.h"

@interface SFViewabilityService : NSObject

+ (instancetype)sharedInstance;

- (void) configureViewabilityPerListingForCell:(UIView *)cell withSFItem:(SFItemData *)sfItem initializationTime:(NSDate *)initializationTime;

- (void) reportViewabilityForOBView:(OBView *)obview;

- (BOOL) isAlreadyReportedForRequestId:(NSString *)requestId position:(NSString *)pos;

- (void) registerOBView:(OBView *)obView positions:(NSArray *)positions requestId:(NSString *)reqId smartFeedInitializationTime:(NSDate *)initializationTime;

- (void) startReportViewabilityWithTimeInterval:(NSInteger)reportingIntervalMillis;

@end
