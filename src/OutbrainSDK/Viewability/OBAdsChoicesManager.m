//
//  OBAdsChoicesManager.m
//  OutbrainSDK
//
//  Created by Oded Regev on 8/2/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import "OBAdsChoicesManager.h"
#import "OBRecommendationResponse.h"
#import "OBAdChoicesGetOperation.h"
#import "Outbrain_Private.h"
#import "Outbrain.h"

@implementation OBAdsChoicesManager

+(void) reportAdsChoicesPixels:(OBRecommendationResponse *)response {
    NSArray *recommendations = response.recommendations;
    NSOperationQueue *obRequestQueue = [[Outbrain mainBrain] obRequestQueue];
    
    for (OBRecommendation *rec in recommendations) {
        if (rec.isRtb) {
            NSLog(@"rec: %@ --> is RTB", rec.content);
            for (NSString *pixelUrl in rec.pixels) {
                NSURL *url = [NSURL URLWithString:pixelUrl];
                NSLog(@"pixel fire: %@", url);
                OBAdChoicesGetOperation *op = [[OBAdChoicesGetOperation alloc] initWithURL:url];
                [obRequestQueue addOperation:op];
            }
        }
    }
}

@end
