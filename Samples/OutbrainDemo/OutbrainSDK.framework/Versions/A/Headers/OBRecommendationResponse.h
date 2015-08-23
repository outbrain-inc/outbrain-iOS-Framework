//
//  OBRecommendationResponse.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/18/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBResponse.h"
#import "OBRecommendation.h"
#import "OBSettings.h"

@class OBSettings;

@interface OBRecommendationResponse : OBResponse

/**
 *  Discussion:
 *      If everything was successful this will be populated
 *      with @OBRecommendation objects.
 **/
@property (nonatomic, strong) NSArray * recommendations;

/**
 *  Discussion:
 *      If everything was successful this will be populated
 *      with @OBSettings object.
 **/
@property (nonatomic, strong) OBSettings * settings;

@end

