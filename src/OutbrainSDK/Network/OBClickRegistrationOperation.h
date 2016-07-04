//
//  OBClickRegistrationOperation.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBOperation.h"

@class OBRecommendation;

/**
 *  Used for handling the click events for a given piece of content
 *
 *  If the request fails for any reason, we'll store this to disk, and then we'll retry at a later date
 **/

@interface OBClickRegistrationOperation : OBOperation

@end
