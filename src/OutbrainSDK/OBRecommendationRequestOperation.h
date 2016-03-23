//
//  OBRecommendationRequestOperation.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/11/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBOperation.h"
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

@interface OBRecommendationRequestOperation : OBOperation

// The request to perform the fetch for
@property (nonatomic, strong) OBRequest * request;


// The final response object
@property (nonatomic, strong) OBRecommendationResponse * response;




@end
