//
//  OBAdsChoicesManager.h
//  OutbrainSDK
//
//  Created by Oded Regev on 8/2/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBRecommendationResponse;

@interface OBAdsChoicesManager : NSObject

+(void) reportAdsChoicesPixels:(OBRecommendationResponse *)response;

@end
