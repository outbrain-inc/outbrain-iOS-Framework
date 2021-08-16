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
@property (nonatomic, assign)   BOOL                    testAppInstall;
@property (nonatomic, assign)   BOOL                    testBrandedCarousel;
@property (nonatomic, copy)     NSString *_Nullable     testLocation;
@property (nonatomic, copy)     NSString * _Nonnull     customUserId;

+(OutbrainManager * _Nonnull) sharedInstance;

-(void) fetchRecommendationsWithRequest:(OBRequest * _Nonnull)request andCallback:(OBResponseCompletionHandler _Nonnull)handler;

-(void) fetchMultivacWithRequest:(OBRequest * _Nonnull)request andDelegate:(id<MultivacResponseDelegate> _Nonnull)multivacDelegate;

-(void) openAppInstallRec:(OBRecommendation * _Nonnull)rec inViewController:(UIViewController * _Nonnull)viewController;

-(void) reportPlistIsValidToServerIfNeeded;

@end
