//
//  MultivacResponseDelegate.h
//  OutbrainSDK
//
//  Created by oded regev on 10/03/2019.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendationResponse.h"

// Internal
@protocol MultivacResponseDelegate  <NSObject>


- (void)onMultivacSuccess:(NSArray<OBRecommendationResponse *> *)cardsResponseArray feedIdx:(NSInteger)feedIdx hasMore:(BOOL)hasMore;

- (void)onMultivacFailure:(NSError *)error;

@end
