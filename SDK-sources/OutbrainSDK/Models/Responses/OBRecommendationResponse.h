//
//  OBRecommendationResponse.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/18/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import "OBResponse.h"
#import "OBRecommendation.h"
#import "OBSettings.h"
#import "OBResponseRequest.h"

@class OBSettings;

/** @brief The object sent as a response to __fetchRecommendationsForRequest__.
 *
 * It contains the following properties:
 * <ul>
 *    <li><strong>recommendations</strong> - an array of content recommendations (OBRecommendation objects).
 *    <li><strong>settings</strong> - your app's OBSettings object.
 *    <li><strong>responseRequest</strong> - the request parameters as they are saved by Outbrain.
 * </ul>
 *
 * @see Outbrain::fetchRecommendationsForRequest
 * @see OBRecommendation
 */
@interface OBRecommendationResponse : OBResponse {
    NSArray     *recommendations;
    OBSettings  *settings;
    OBResponseRequest   *responseRequest;
}


FOUNDATION_EXPORT NSString *const kSDK_SHOULD_RETURN_PAID_REDIRECT_URL;


/**
 *  @brief An array of content recommendations (OBRecommendation objects).
 **/
@property (nonatomic, strong) NSArray * recommendations;

/**
 *  @brief Your app's OBSettings object.
 **/
@property (nonatomic, strong) OBSettings * settings;

/**
 *  @brief The request parameters as they are saved by Outbrain.
 **/
@property (nonatomic, strong) OBResponseRequest * responseRequest;

@end
