//
//  OBResponse.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/18/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import "OBContent.h"
@class OBRequest;


/**
 *  This is a base class for a response from the Outbrain API
 **/


@interface OBResponse : OBContent
{
    @private
        OBRequest *_request;
        NSError *_error;
}

/**
 *  Discussion:
 *      The request that the response was generated for
 *      Should never be nil
 **/
@property (nonatomic, strong) OBRequest * request;


/**
 *  Discussion:
 *      If this is set then there was some kind of error in 
 *      the process of getting this response.  Check @OBErrors for 
 *      a reference of different error scenarios.  If this is non-nil,
 *      then you can expect `nil` for `recommendations`
 *
 *  Defaults: nil
 **/
@property (nonatomic, strong) NSError * error;


@end
