//
//  SFViewabilityService.h
//  OutbrainSDK
//
//  Created by Alon Shprung on 2/28/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBView.h"

@interface SFViewabilityService : NSObject

+ (instancetype)sharedInstance;

- (void) reportViewabilityForOBView:(OBView *)obview;

- (BOOL) isAlreadyReportedForRequestId:(NSString *)requestId position:(NSString *)pos;

- (void) startReportViewability;

@end
