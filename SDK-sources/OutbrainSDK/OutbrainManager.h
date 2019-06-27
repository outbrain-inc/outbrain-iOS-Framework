//
//  OutbrainManager.h
//  OutbrainSDK
//
//  Created by oded regev on 13/06/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRequest.h"
#import "OBProtocols.h"
#import "MultivacResponseDelegate.h"

@interface OutbrainManager : NSObject

@property (nonatomic, copy)     NSString *  partnerKey;
@property (nonatomic, assign)   BOOL        testMode;
@property (nonatomic, assign)   BOOL        testRTB;
@property (nonatomic, copy)     NSString *  testLocation;

+(OutbrainManager *) sharedInstance;

-(void) fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler;

-(void) fetchMultivacWithRequest:(OBRequest *)request andDelegate:(id<MultivacResponseDelegate>)multivacDelegate;

@end
