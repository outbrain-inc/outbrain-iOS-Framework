//
//  OBViewabilityService.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/16/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBViewabilityService.h"

#define VIEWED_RECOMMENDATIONS_LIST_KEY @"VIEWED_RECOMMENDATIONS_LIST_KEY"

@implementation OBViewabilityService

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)addRecommendationToViewedRecommendationsList:(OBRecommendation *)recommendation {
    viewedRecommendationsList = [self fetchArrayFromUserDefaults];
    if (viewedRecommendationsList == nil || [viewedRecommendationsList count] == 0) {
        viewedRecommendationsList = [[NSMutableArray alloc] init];
    }
    BOOL isDuplicateRec = NO;
    for (OBRecommendation *rec in viewedRecommendationsList) {
        if ([rec.sourceURL isEqual:recommendation.sourceURL]) {
            isDuplicateRec = YES;
            break;
        }
    }
    if (!isDuplicateRec) {
        [viewedRecommendationsList addObject:recommendation];
    }
    [self storeArrayToUserDefaults];
}

- (void)reportRecommendations {
    viewedRecommendationsList = [self fetchArrayFromUserDefaults];
    int i = 0;
    for (OBRecommendation *rec in viewedRecommendationsList) {
        i++;
        NSLog(@"rec %d = %@", i ,rec.content);
    }
    [viewedRecommendationsList removeAllObjects];
    //TODO: Report this
}

- (void)storeArrayToUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:viewedRecommendationsList];
    [defaults setObject:data forKey:VIEWED_RECOMMENDATIONS_LIST_KEY];
    [defaults synchronize];
}

- (NSMutableArray *)fetchArrayFromUserDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:VIEWED_RECOMMENDATIONS_LIST_KEY];
    NSMutableArray *myArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [defaults synchronize];
    return myArray;
}

@end
