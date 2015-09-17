//
//  OBViewabilityService.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/16/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendation.h"

@interface OBViewabilityService : NSObject {
    NSMutableArray          *viewedRecommendationsList;
}

- (void)addRecommendationToViewedRecommendationsList:(OBRecommendation *)recommendation;
- (void)reportRecommendations;

@end
