//
//  OBBridge.h
//  OutbrainSDK
//
//  Created by Oded Regev on 7/4/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OBBridge : NSObject

/** @section Custom OBWebView **/

+ (BOOL) isOutbrainPaidUrl:(NSURL *)url;

+ (BOOL) shouldOpenInSafariViewController:(NSURL *)url;

// Return status - success or failure
+ (BOOL) registerOutbrainResponse:(NSDictionary *)jsonDictionary;



/** @section Initilize Outbrain **/

/**
 *  @brief Initializes Outbrain with the partner key you've received from your Outbrain Account Manager.
 *
 *  A partner key uniquely identifies an Outbrain customer.
 *
 *  @note Call this method once during your app's initialization, before calling any other method. The best practice is to call it \n
 *  in the onCreate function of the first Activity, or when generating the ApplicationContext, if your app has one.
 *
 *  @param partnerKey - the partner key you've received from your Outbrain Account Manager.
 *
 *  @see initializeOutbrainWithConfigFile
 **/
+ (void)initializeOutbrainWithPartnerKey:(NSString *)partnerKey;

@end
