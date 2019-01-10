//
//  OBRecommendation.h
//  OutbrainSDK
//
//  Created by Oded Regev on 12/12/13.
//  Copyright (c) 2017 Outbrain. All rights reserved.
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
 *    <li><strong>redirectURL</strong> - the recommendation redirect URL.
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
@class OBDisclosure;

@interface OBRecommendation : OBContent

/** @brief The date the content was published. */
@property (nonatomic, strong, readonly, nullable) NSDate * publishDate;
/** @brief TBD - property may be removed. */
@property (nonatomic, copy, readonly, nullable) NSString * author;
/** @brief The recommendation's title. */
@property (nonatomic, copy, readonly, nonnull) NSString * content;
/** @brief The name of the recommendation's source. */
@property (nonatomic, copy, readonly, nonnull) NSString * source;
/** @brief Is the recommendation from the same source as the one the user is currently viewing. */
@property (nonatomic, assign, getter = isSameSource, readonly) BOOL sameSource;
/** @brief Is this a recommendation for which the publisher pays, when your user clicks on it. */
@property (nonatomic, assign, getter = isPaidLink, readonly) BOOL paidLink;
/** @brief Is the recommendation a link to a video clip. */
@property (nonatomic, assign, getter = isVideo, readonly) BOOL video;
/** @brief An image related to the recommendation. */
@property (nonatomic, strong, readonly, nullable) OBImage *image;
/** @brief Publisher logo image */
@property (nonatomic, strong, readonly, nullable) OBImage *publisherLogoImage;
/** @brief Disclosure icon for conversion campaigns */
@property (nonatomic, strong, readonly, nullable) OBDisclosure *disclosure;
/** @brief Pixels array for a recommendation to be fired when recommendation received from the server */
@property (nonatomic, strong, readonly, nullable) NSArray *pixels;
/** @brief The audience campaigns label - null if not audience campaigns. */
@property (nonatomic, copy, readonly, nullable) NSString * audienceCampaignsLabel;

-(BOOL) isRTB __deprecated_msg("use shouldDisplayDisclosureIcon() instead.");

-(BOOL) shouldDisplayDisclosureIcon;

- (NSString *)description;

@end
