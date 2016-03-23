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

- (void) reportRecsReceived:(OBRecommendationResponse *)response;

- (void) reportRecsShownForWidgetId:(NSString *)widgetId;



@end
