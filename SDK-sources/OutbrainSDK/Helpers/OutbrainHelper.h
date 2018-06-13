//
//  OutbrainHelper.h
//  OutbrainSDK
//
//  Created by Oded Regev on 7/6/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendationsTokenHandler.h"

@class OBResponse;
@class OBRequest;


@interface OutbrainHelper : NSObject

@property (nonatomic, strong) OBRecommendationsTokenHandler *tokensHandler;


+ (OutbrainHelper *) sharedInstance;

- (NSArray *) advertiserIdURLParams;

- (void) updateODBSettings:(OBResponse *)response;

- (NSURL *) recommendationURLForRequest:(OBRequest *)request;

@end
