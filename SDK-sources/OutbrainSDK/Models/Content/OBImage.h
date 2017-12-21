//
//  OBImage.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/12/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import <CoreGraphics/CGGeometry.h>
#import <Foundation/NSURL.h>
#import "OBContent.h"



/** @brief Represents a thumbnail image to be displayed with the recommendation.
 *
 * It contains the following properties:
 * <ul>
 *    <li><strong>url</strong> - a URL pointing to the image file.
 *	  <li><strong>width</strong> - the image width pixels.
 *    <li><strong>height</strong> - the image height in pixels.
 * </ul>
 *
 */
@interface OBImage : OBContent {
    NSURL           *url;
    CGFloat         width;
    CGFloat         height;
}

/** @brief The image URL */
@property (nonatomic, copy) NSURL *url;

/** @brief The image width in pixels. */
@property (nonatomic, assign) CGFloat width;

/** @brief The image height in pixels. */
@property (nonatomic, assign) CGFloat height;

@end
