//
//  OBRecommendation.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBContent.h"
#import "OBImage.h"


/**
 *  Represents a single recommendation from outbrain
 **/

@interface OBRecommendation : OBContent

@property (nonatomic, strong) NSDate * publishDate;
@property (nonatomic, strong) NSURL * sourceURL;

@property (nonatomic, copy) NSString * author;
@property (nonatomic, copy) NSString * content;
@property (nonatomic, copy) NSString * source;


@property (nonatomic, assign, getter = isSameSource) BOOL sameSource;
@property (nonatomic, assign, getter = isPaidLink) BOOL paidLink;
@property (nonatomic, assign, getter = isVideo) BOOL video;

/**
 *  Discussion:
 *      The image object returned from the recommendation response.
 *
 *  Defaults:  nil
 **/
@property (nonatomic, strong) OBImage *image;

@end
