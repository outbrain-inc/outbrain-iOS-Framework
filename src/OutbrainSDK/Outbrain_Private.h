//
//  Outbrain_Private.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/23/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendationsTokenHandler.h"
#import "OBViewabilityService.h"


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
    __unsafe_unretained NSString * testModeKey;
    
} OBSettingsAttributes;

/**
 *  Some private outbrain things that we want access to in other places
 **/

@interface Outbrain()

@property (nonatomic, strong) NSOperationQueue * obRequestQueue;    // Our operation queue
@property (nonatomic, strong) OBViewabilityService *viewabilityService;

+ (instancetype)mainBrain;  // Shared Instance

// Use the OBSettingsAttributes as the keys
// May open this up to users
+ (void)initializeOutbrainWithDictionary:(NSDictionary *)dict;

@end




// Separating these for cleanness
@interface Outbrain (InternalMethods)

+ (void)_fetchRecommendationsWithRequest:(OBRequest *)request andCallback:(OBResponseCompletionHandler)handler;

@end