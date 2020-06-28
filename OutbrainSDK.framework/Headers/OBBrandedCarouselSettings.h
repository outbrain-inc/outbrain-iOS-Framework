//
//  OBBrandedCarouselSettings.h
//  OutbrainSDK
//
//  Created by oded regev on 25/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Outbrain.h"
#import "OBImageInfo.h"

@interface OBBrandedCarouselSettings : NSObject



- (instancetype _Nonnull )initWithPayload:(NSDictionary * _Nullable)payload;

/** @brief The carousel title. */
@property (nonatomic, copy, readonly, nullable) NSString * carouselTitle;
/** @brief The name of the carousel sponser. */
@property (nonatomic, copy, readonly, nullable) NSString * carouselSponsor;
/** @brief The carousel type. */
@property (nonatomic, copy, readonly, nullable) NSString * carouselType;
/** @brief The url to open on click. */
@property (nonatomic, strong, readonly, nullable) NSURL * carouselClickUrl;

/** @brief An image to display on the card title. */
@property (nonatomic, strong, readonly, nullable) OBImageInfo *image;

@end


