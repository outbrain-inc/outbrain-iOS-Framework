//
//  OutbrainHelper.h
//  OutbrainSDK
//
//  Created by Oded Regev on 7/6/16.
//  Copyright © 2016 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OBRecommendationsTokenHandler.h"

@class OBResponse;
@class OBRequest;


@interface OutbrainHelper : NSObject

@property (nonatomic, strong) OBRecommendationsTokenHandler *tokensHandler;


+ (OutbrainHelper *) sharedInstance;


/**
 *  Discussion:
 *      Retrieve an internal setting for the given key
 *
 *  params:
 *      @key - The key to return the setting for
 **/
- (id) sdkSettingForKey:(NSString *)key;

/**
 *  Discussion:
 *      This method is used to set an internal setting.  You can retrieve these values
 *      from the `- sdkSettingForKey:` method or by using the `@settings` property directly
 *
 *  params:
 *      @value - The value for the @key you wish to set.
 *      @key - The key you wish to set a value for
 *
 *  @note:  Passing nil for @value will delete the value for the given @key
 **/
- (void)setSDKSettingValue:(id)value forKey:(NSString *)key;

- (NSArray *) advertiserIdURLParams;

- (void) updateODBSettings:(OBResponse *)response;

- (NSURL *) recommendationURLForRequest:(OBRequest *)request;

- (NSString *)partnerKey;

-(void) prepare:(UIImageView *)imageView withRTB:(OBRecommendation *)rec onClickBlock:(OBOnClickBlock)block;

@end
