//
//  OBRecommendationResponse.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/18/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendationResponse.h"
#import "OBContent_Private.h"


@implementation OBRecommendationResponse

+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBRecommendationResponse * res = [super contentWithPayload:payload];
    
    id documents = payload[@"documents"];
    if([documents isKindOfClass:[NSDictionary class]])
    {
        // The actual docs here
        if(documents[@"doc"] && [documents[@"doc"] isKindOfClass:[NSArray class]])
        {
            // Let's convert the recommendations to actual objects
            NSMutableArray * recommendations = [NSMutableArray arrayWithCapacity:[documents[@"doc"] count]];
            for(id rec in documents[@"doc"])
            {
                [recommendations addObject:[OBRecommendation contentWithPayload:rec]];
            }
            res.recommendations = [recommendations copy];
        }
    }
    
    id settingsPayload = payload[@"settings"];
    if([settingsPayload isKindOfClass:[NSDictionary class]])
    {
        // The actual docs here
        // Let's convert the recommendations to actual objects

        res.settings = [[OBSettings alloc] initWithPayload:settingsPayload];
    }

    
    return res;
}

+ (NSArray *)requiredKeys
{
    return @[@"documents"];
}

@end
