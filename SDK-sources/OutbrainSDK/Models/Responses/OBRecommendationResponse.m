//
//  OBRecommendationResponse.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/18/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "OBRecommendationResponse.h"
#import "OBContent_Private.h"


@implementation OBRecommendationResponse


+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBRecommendationResponse * res = [super contentWithPayload:payload];
    
    // Parse settings
    id settingsPayload = payload[@"settings"];
    if([settingsPayload isKindOfClass:[NSDictionary class]])
    {
        // The actual docs here
        // Let's convert the recommendations to actual objects
        res.settings = [[OBSettings alloc] initWithPayload:settingsPayload];
    }
    
    // Parse documents, i.e. recommadations
    id documents = payload[@"documents"];
    if([documents isKindOfClass:[NSDictionary class]])
    {
        // The actual docs here
        if(documents[@"doc"] && [documents[@"doc"] isKindOfClass:[NSArray class]])
        {
            // Let's convert the recommendations to actual objects
            NSMutableArray * recommendations = [NSMutableArray arrayWithCapacity:[documents[@"doc"] count]];
            for (NSDictionary *rec in documents[@"doc"])
            {
                [recommendations addObject:[OBRecommendation contentWithPayload:rec]];
            }
            res.recommendations = [recommendations copy];
        }
    }
    
    // Parse request
    id requestPayload = payload[@"request"];
    if([requestPayload isKindOfClass:[NSDictionary class]])
    {
        // The response request here
        res.responseRequest = [[OBResponseRequest alloc] initWithPayload:requestPayload];
    }
 
    return res;
}

+ (NSArray *)requiredKeys
{
    return @[@"documents"];
}

@end
