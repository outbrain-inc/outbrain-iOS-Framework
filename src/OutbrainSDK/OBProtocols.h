//
//  OutbrainRecommendationDelegate.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/17/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/NSObject.h>

@class OBResponse;
@class OBRecommendationResponse;


/** @section Callback Handlers **/

/**
 *  @name: OBRecommendationsCompletionHandler
 *  @params:
 *      response:                         The response object from outbrain.  Will be a subclass of `OBResponse`
 **/
typedef void(^OBResponseCompletionHandler)(OBRecommendationResponse *response);

@protocol OBResponseDelegate  <NSObject>

/**
 *  Discussion:
 *      This will be called when we successfully fetched recommendations for the given link
 **/
- (void)outbrainDidReceiveResponseWithSuccess:(OBRecommendationResponse *)response;


/**
 *  Discussion:
 *      This is called when any amount of errors occurs after a request is made.  The
 *      error property will be set on the response object directly
 **/
- (void)outbrainResponseDidFail:(NSError *)response;
@end
