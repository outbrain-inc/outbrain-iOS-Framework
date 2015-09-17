//
//  OBImage.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <Foundation/NSURL.h>
#import "OBContent.h"



/**
 *  Represents an image in a recommendation
 **/

@interface OBImage : OBContent

/**
 *  Discussion:
 *      The url to fetch the actual image
 *  
 *  Defaults: nil
 **/
@property (nonatomic, copy) NSURL *url;


/**
 *  Discussion: 
 *      The height and width of the image. (if available).
 *
 *  Defaults: 0
 **/
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;


@end
