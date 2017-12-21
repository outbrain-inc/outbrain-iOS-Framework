//
//  OBErrors.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/10/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 *  Discussion:
 *      Here are some defined error keys that we use for returning errors to you.
 *      If there is an original native error we will pass this back in the `NSUnderlyingErrorKey`
 **/



/**
 *  Any errors that are from the api requests to the server.
 **/
extern NSString * const OBGenericErrorDomain;

/**
 *  Any errors that occurred as response to application code.
 *  (e.g Invalid json parsing, properties not set, etc...)
 **/
extern NSString * const OBNativeErrorDomain;

/**
 *  Discussion:
 *      Network error.  This represents a timeout, internal server error, etc.
 **/
extern NSString * const OBNetworkErrorDomain;

/**
 *  Discussion:
 *      This referes to a recommendation response that was successful, but returned
 *      0 recommendations.  This doesn't happen often, but it does happen.
 *      If you ever get this error you can either retry the request, or you can
 *      just ignore this particular request altogether.
 **/
extern NSString * const OBZeroRecommendationseErrorDomain;


typedef NS_ENUM(NSUInteger, OBErrorCode) {
    OBGenericErrorCode      =   10200,
    OBParsingErroCode       =   10201,
    OBServerErrorCode       =   10202,
    
    /**
     *  This code comes up if either your partnerKey or widgetID are invalid
     **/
    OBInvalidParametersErrorCode    =   10203,
    OBNoRecommendationsErrorCode    =   10204
};
