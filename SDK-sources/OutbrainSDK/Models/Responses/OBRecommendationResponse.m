//
//  OBRecommendationResponse.m
//  OutbrainSDK
//
//  Created by Oded Regev on 12/18/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendationResponse.h"
#import "OBContent_Private.h"


@implementation OBRecommendationResponse

NSString *const kSDK_SHOULD_RETURN_PAID_REDIRECT_URL = @"sdkShouldReturnPaidRedirectUrl";


+ (instancetype)contentWithPayload:(NSDictionary *)payload
{
    OBRecommendationResponse * res = [super contentWithPayload:payload];
    NSNumber *sdkShouldReturnPaidRedirectUrl = nil;
    
    // Parse settings
    id settingsPayload = payload[@"settings"];
    if([settingsPayload isKindOfClass:[NSDictionary class]])
    {
        // The actual docs here
        // Let's convert the recommendations to actual objects

        res.settings = [[OBSettings alloc] initWithPayload:settingsPayload];
        sdkShouldReturnPaidRedirectUrl = [res.settings getNSNumberValueForSettingKey:kSDK_SHOULD_RETURN_PAID_REDIRECT_URL];
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
                NSMutableDictionary *mutableRec = [rec mutableCopy];
                mutableRec[kSDK_SHOULD_RETURN_PAID_REDIRECT_URL] = sdkShouldReturnPaidRedirectUrl;
                [recommendations addObject:[OBRecommendation contentWithPayload:mutableRec]];
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

#pragma mark - Getters & Setters

- (NSArray *)recommendations {
    return recommendations;
}

- (void)setRecommendations:(NSArray *)aRecommendations {
    recommendations = aRecommendations;
}

- (OBSettings *)settings {
    return settings;
}

- (void)setSettings:(OBSettings *)aSettings {
    settings = aSettings;
}

- (OBResponseRequest *)responseRequest {
    return responseRequest;
}

- (void)setResponseRequest:(OBResponseRequest *)aResponseRequest {
    responseRequest = aResponseRequest;
}
@end
