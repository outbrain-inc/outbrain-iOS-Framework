//
//  OBAdsChoicesManager.m
//  OutbrainSDK
//
//  Created by Oded Regev on 8/2/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import "OBAdsChoicesManager.h"
#import "OBRecommendationResponse.h"
#import "OBNetworkManager.h"
#import "Outbrain_Private.h"
#import "Outbrain.h"

@implementation OBAdsChoicesManager

+(void) reportAdsChoicesPixels:(OBRecommendationResponse *)response {
    NSArray *recommendations = response.recommendations;
    
    for (OBRecommendation *rec in recommendations) {
        if (rec.isRtb) {
            NSLog(@"rec: %@ --> is RTB", rec.content);
            for (NSString *pixelUrl in rec.pixels) {
                NSURL *url = [NSURL URLWithString:pixelUrl];
                NSLog(@"pixel fire: %@", url);
                [[OBNetworkManager sharedManager] sendGet:url completionHandler:nil];
            }
        }
    }
}

@end
