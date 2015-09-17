//
//  OutbrainSDKTests.m
//  OutbrainSDKTests
//
//  Created by Joseph Ridenour on 12/9/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "OBAsyncTest.h"
#import "OutbrainSDK.h"
#import "Outbrain_Private.h"

#import "OBDefines.h"

@interface OutbrainSDKTests : OBAsyncTest
@end


#define OB_TEST_PARTNER_KEY OBDemoPartnerKey

@implementation OutbrainSDKTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFileInitialization
{
    STAssertThrows([Outbrain initializeOutbrainWithConfigFile:@"OBConfig.jsonblah"], @"Should not allow invalid file path");
    STAssertNoThrow([Outbrain initializeOutbrainWithConfigFile:@"OBConfig.json"], @"Should allow valid json config file");
    STAssertNoThrow([Outbrain initializeOutbrainWithConfigFile:@"OBConfig.plist"], @"Should allow valid plist config file");
    STAssertNoThrow([Outbrain initializeOutbrainWithConfigFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"OBConfig" ofType:@"plist"]], @"Should support full path");
    STAssertNotNil([[Outbrain mainBrain] settings][OBSettingsAttributes.partnerKey], @"PartnerKey should be set properly");
    
    STAssertNoThrow([Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:OB_TEST_PARTNER_KEY}], @"Should work with valid dictionary");
    STAssertThrows([Outbrain initializeOutbrainWithDictionary:@{}], @"Should not allow empty dictionary");
}

- (void)testCallingBeforeInitialized
{
    [Outbrain mainBrain].settings = [@{} mutableCopy];
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:@"AR_1"];
    STAssertThrows([Outbrain fetchRecommendationsForRequest:request withCallback:nil], @"Should fail if not initialized");
}

- (void)testShouldFetchRecommendations
{
    [Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:OB_TEST_PARTNER_KEY}];
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:@"AR_1"];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBResponse *response) {
        self.done = YES;
    }];
    STAssertTrue([self waitForCompletion:20], @"Should not timeout");
}

- (void)testAppUserToken
{
    [Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:OB_TEST_PARTNER_KEY}];
    
    NSString * token = [Outbrain OBSettingForKey:OBSettingsAttributes.appUserTokenKey];
    STAssertNotNil(token, @"User token should not be nil");
    STAssertTrue([Outbrain _saveUserTokenInKeychain:token], @"Should be able to save to keychain");
    STAssertNotNil([Outbrain _getUserTokenFromKeychainIfAvailable], @"User token should be saved in keychain");
    STAssertTrue([token isEqualToString:[Outbrain _getUserTokenFromKeychainIfAvailable]], @"Keychain token should equal property");
}



@end
