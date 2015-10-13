//
//  Outbrain_Private.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/23/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendationsTokenHandler.h"
#import "OBViewabilityService.h"
#import "OBGAHelper.h"

/**
 *  These are some keys we're defining for various lookups 
 *  Mostly for lookup in the `settings` dictionary
 **/
extern const struct OBSettingsAttributes {
    // Settings dictionary keys
	__unsafe_unretained NSString * partnerKey;              // The PartnerKey
    __unsafe_unretained NSString * appUserTokenKey;         // The key for the generated token for declaring a unique device
    
    // Keychain keys
    __unsafe_unretained NSString * keychainIdentifierKey;       // The key we're storing the appUserToken under
    __unsafe_unretained NSString * keychainServiceUsernameKey;  // The name we're storing keychain data under
    __unsafe_unretained NSString * keychainServiceNameKey;      // The service name we're registering data under in the keychain
    
    // Misc.
    __unsafe_unretained NSString * udTokenKey;                  // The key for retrieving the appUserToken from user defaults
    __unsafe_unretained NSString * apvRequestCacheKey;          // This is our apv records
    __unsafe_unretained NSString * testModeKey;
    
} OBSettingsAttributes;

/**
 *  Some private outbrain things that we want access to in other places
 **/

@interface Outbrain()
@property (nonatomic, strong) NSOperationQueue * obRequestQueue;    // Our operation queue
@property (nonatomic, strong) NSMutableDictionary *obSettings;       // Settings payload that the sdk is initialized with
@property (nonatomic, strong) OBRecommendationsTokenHandler *tokensHandler;
@property (nonatomic, strong) OBViewabilityService *viewabilityService;
@property (nonatomic, strong) OBGAHelper *gaHelper;

+ (instancetype)mainBrain;  // Shared Instance

// Use the OBSettingsAttributes as the keys
// May open this up to users
+ (void)initializeOutbrainWithDictionary:(NSDictionary *)dict;

@end



// Some Convenience Getters
@interface Outbrain(ConvenienceGetters)

+ (NSString *)partnerKey;
+ (NSString *)userToken;

@end



// Separating these for cleanness
@interface Outbrain (InternalMethods)

// apv cache
+ (void)_updateAPVCacheForResponse:(OBResponse *)response;

// URL Builder
+ (NSURL *)_recommendationURLForRequest:(OBRequest *)request;

+ (void)_fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler;

// Convenience for setting/getting `settings`

/**
 *  Discussion:
 *      Retrieve an internal setting for the given key
 *
 *  params:
 *      @key - The key to return the setting for
 **/
+ (id)OBSettingForKey:(NSString *)key;

/**
 *  Discussion:
 *      This method is used to set an internal setting.  You can retrieve these values
 *      from the `+ OBSettingForKey:` method or by using the `@settings` property directly
 *
 *  params:
 *      @value - The value for the @key you wish to set.
 *      @key - The key you wish to set a value for
 *
 *  @note:  Passing nil for @value will delete the value for the given @key
 **/
+ (void)setOBSettingValue:(id)value forKey:(NSString *)key;

@end