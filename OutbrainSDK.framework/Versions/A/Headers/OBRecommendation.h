//
//  OBRecommendation.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/12/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBContent.h"
#import "OBImage.h"


/** @brief An interface that represents a single content recommendation.
 *
 * The OBRecommendationResponse object that you receive in response to a __fetchRecommendationsForRequest__ request contains a list of OBRecommendation objects.\n
 * Each OBRecommendation contains the following properties:\n
 * <ul>
 *    <li><strong>isVideo</strong> - is there a video embedded in the recommended article.
 *    <li><strong>isPaidLink</strong> - is this a recommendation for which the publisher pays, when your user clicks on it.
 *    <li><strong>image</strong> - an image to be displayed with the recommendation.
 *    <li><strong>content</strong> - the recommendation's title.
 *    <li><strong>author</strong> - the author of the recommendation's content.
 *    <li><strong>sourceURL</strong> - the recommendation URL.
 *    <li><strong>publishDate</strong> - the date the content was published.
 *    <li><strong>isSameSource</strong> - is the recommendation from the same source as the one the user is currently viewing.
 *    <li><strong>source</strong> - the name of the recommendation's source.
 * </ul>
 *
 * @note Please see the "Outbrain iOS SDK Programming Guide" for more detailed explanations about how to integrate with Outbrain.
 *
 * @see OBRecommendationResponse
 * @see OBImage
 */
@interface OBRecommendation : OBContent {
    NSDate * publishDate;
    NSURL * sourceURL;
    NSString * author;
    NSString * content;
    NSString * source;

    BOOL sameSource;
    BOOL paidLink;
    
    BOOL video;
    OBImage *image;
}

/** @brief The date the content was published. */
@property (nonatomic, strong) NSDate * publishDate;
@property (nonatomic, strong) NSURL * sourceURL;
/** @brief TBD - property may be removed. */
@property (nonatomic, copy) NSString * author;
/** @brief The recommendation's title. */
@property (nonatomic, copy) NSString * content;
/** @brief The name of the recommendation's source. */
@property (nonatomic, copy) NSString * source;
/** @brief Is the recommendation from the same source as the one the user is currently viewing. */
@property (nonatomic, assign, getter = isSameSource) BOOL sameSource;
/** @brief Is this a recommendation for which the publisher pays, when your user clicks on it. */
@property (nonatomic, assign, getter = isPaidLink) BOOL paidLink;
/** @brief Is the recommendation a link to a video clip. */
@property (nonatomic, assign, getter = isVideo) BOOL video;
/** @brief An image related to the recommendation. */
@property (nonatomic, strong) OBImage *image;

@end
