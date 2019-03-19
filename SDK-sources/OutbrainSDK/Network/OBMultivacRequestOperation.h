//
//  OBMultivacRequestOperation.h
//  OutbrainSDK
//
//  Created by oded regev on 10/03/2019.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBProtocols.h"
#import "MultivacResponseDelegate.h"

@class OBRequest;
@class OBRecommendationResponse;


@interface OBMultivacRequestOperation : NSOperation

- (instancetype)initWithRequest:(OBRequest *)request;

@property (nonatomic, weak) id<MultivacResponseDelegate> multivacDelegate;

@end

