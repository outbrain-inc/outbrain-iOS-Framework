//
//  OBSkAdNetworkData.h
//  OutbrainSDK
//
//  Created by Oded Regev on 06/09/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <OutbrainSDK/OutbrainSDK.h>



@interface OBSkAdNetworkData : OBContent

// See https://developer.apple.com/documentation/storekit/skadnetwork/generating_the_signature_to_validate_an_installation


/** @brief AdNetwork ID on Apple  */
@property (nonatomic, copy, nullable) NSString *adNetworkId;

/** @brief campaign ID -  A campaign number the ad network provide */
@property (nonatomic, copy, nullable) NSNumber *campaignId;

/** @brief The app install iTunes ID */
@property (nonatomic, copy, nullable) NSString *iTunesItemId;

/** @brief A unique UUID value the ad network provides for each ad impression */
@property (nonatomic, copy, nullable) NSString *nonce;

/** @brief A timestamp the ad network generate near the time of the ad impression */
@property (nonatomic, assign) long timestamp;

/** @brief The App Store ID of the app displaying the ad */
@property (nonatomic, copy, nullable) NSString *sourceAppId;

/** @brief Version 2.0. Use the API version value “2.0” */
@property (nonatomic, copy, nullable) NSString *skNetworkVersion;

/** @brief the binary signature the ad network generated encoded into a Base64 string */
@property (nonatomic, copy, nullable) NSString *signature;

@end


