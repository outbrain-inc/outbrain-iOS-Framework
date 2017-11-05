//
//  OBRecommendationRequestOperation.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/11/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBProtocols.h"

@class OBRequest;
@class OBRecommendationResponse;

/** @name INTERNAL CLASS **/

/**
 *  This is the meat of Outbrain.
 *  This operation will:
 *  1.  Fetch the recomendations from the api.
 *  2.  Handle any errors in the request/response
 *  3.  Parse the data into objects.
 **/

@interface OBRecommendationRequestOperation : NSObject

- (instancetype)initWithRequest:(OBRequest *)request;

-(void) start;

// The request to perform the fetch for
@property (nonatomic, strong) OBResponseCompletionHandler handler;

@end
