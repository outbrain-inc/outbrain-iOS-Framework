//
//  CustomWebViewManager.h
//  OutbrainSDK
//
//  Created by Oded Regev on 6/23/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomWebViewManager : NSObject


extern NSString * const kCustomWebViewReportingEnabledKey;
extern NSString * const kCustomWebViewThresholdKey;


+ (id)sharedManager;

- (void) reportServerOnPercentLoad:(float)percentLoad forUrl:(NSString *)urlString orignalPaidOutbrainUrl:(NSString *)orignalPaidOutbrainUrl loadStartDate:(NSDate *)loadStartDate;

- (void) checkUrlAndReportIfNeeded:(id)uiwebView_or_wkwebview;

- (void) reportOnProgressAndReportIfNeeded:(float)progress webview:(id)uiwebView_or_wkwebview;

- (void) updateCWVSetting:(NSNumber *)value key:(NSString *)key;
    
@end
