//
//  OutbrainRecommendationDelegate.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/17/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import <Foundation/NSObject.h>

@class OBResponse;
@class OBRecommendationResponse;


/** @section Callback Handlers **/

/**
 *  @brief An event handler for receiving and handling the OBRecommendationResponse object.
 *
 *  OBRecommendationResponse is sent in response to calling Outbrain::fetchRecommendationsForRequest.
 *
 *  @param response - the recommendations response object.
 *
 *  @see OBRecommendationResponse
 *  @see Outbrain::fetchRecommendationsForRequest
 **/
typedef void(^OBResponseCompletionHandler)(OBRecommendationResponse *response);

/**
 *  @brief A delegate for receiving and handling the OBRecommendationResponse object, or an error object if the request failed.
 *
 *  OBRecommendationResponse is sent in response to calling Outbrain::fetchRecommendationsForRequest.
 *
 *  @see OBRecommendationResponse
 *  @see Outbrain::fetchRecommendationsForRequest
 **/
@protocol OBResponseDelegate  <NSObject>

/**
 *  @brief This method will be called when a recommendation request is successful.
 *
 *  @param response - the recommendations response object.
 *
 *  @see OBRecommendationResponse
 **/
- (void)outbrainDidReceiveResponseWithSuccess:(OBRecommendationResponse *)response;


/**
 *  @brief This method will be called when a recommendation request fails.
 *
 *  @param response - an error object describing the failure's cause.
 **/
- (void)outbrainResponseDidFail:(NSError *)response;
@end
