//
//  OBGAHelper.h
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/19/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBGAHelper : NSObject {
}

+ (void)setAppKey:(NSString *)appKey;
+ (void)setAppVersion:(NSString *)version;
+ (void)reportMethodCalled:(NSString *)methodName;
+ (void)reportMethodCalled:(NSString *)methodName withParams:(NSString *)firstParam, ... NS_REQUIRES_NIL_TERMINATION;
+ (void)reportMethodCalled:(NSString *)methodName withConcreteParams:(NSString *)paramsString shouldForceSend:(BOOL)forceSend;
+ (void)setShouldReportSDKUsage:(BOOL)shouldReportSDKUsage;

@end
