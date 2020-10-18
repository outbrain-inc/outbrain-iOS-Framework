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

@property (nonatomic, copy)     NSString * _Nonnull     partnerKey;
@property (nonatomic, assign)   BOOL                    testMode;
@property (nonatomic, assign)   BOOL                    testRTB;
@property (nonatomic, copy)     NSString *_Nullable     testLocation;

+(OutbrainManager * _Nonnull) sharedInstance;

-(void) fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler;

-(void) fetchMultivacWithRequest:(OBRequest *)request andDelegate:(id<MultivacResponseDelegate>)multivacDelegate;

-(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inNavController:(UINavigationController * _Nonnull)navController;

-(void) reportPlistIsValidToServerIfNeeded;

@end
