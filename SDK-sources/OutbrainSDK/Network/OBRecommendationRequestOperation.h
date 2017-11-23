//
//  OBRecommendationRequestOperation.h
//  OutbrainSDK
//
//  Created by Oded Regev on 6/11/17.
//  Copyright (c) 2017 Outbrain inc. All rights reserved.
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

@interface OBRecommendationRequestOperation : NSOperation

- (instancetype)initWithRequest:(OBRequest *)request;

// The request to perform the fetch for
@property (nonatomic, strong) OBResponseCompletionHandler handler;

@end
