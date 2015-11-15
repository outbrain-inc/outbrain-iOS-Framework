//
//  OBRecommendationsTokenHandler.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRequest.h"
#import "OBRecommendationResponse.h"

@interface OBRecommendationsTokenHandler : NSObject {

}

- (NSString *)getTokenForRequest:(OBRequest *)request;
- (void)setTokenForRequest:(OBRequest *)request response:(OBRecommendationResponse *)response;

@end