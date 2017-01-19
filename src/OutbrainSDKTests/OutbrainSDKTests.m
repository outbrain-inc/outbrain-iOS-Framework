//
//  OutbrainSDKTests.m
//  OutbrainSDKTests
//
//  Created by Joseph Ridenour on 12/9/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <XCTest/XCTest.h>
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
    [Outbrain setSharedInstance:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitializeFromEmptyDictionary {
    XCTAssertThrows([Outbrain initializeOutbrainWithDictionary:@{}], @"Should not allow empty dictionary");
}


- (void)testShouldFetchRecommendations
{
    [Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:OB_TEST_PARTNER_KEY}];
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:@"AR_1"];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBResponse *response) {
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:20], @"Should not timeout");
}


- (void)testAppUserToken
{
    [Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:OB_TEST_PARTNER_KEY}];
   // NSString *partnerKey = [[OutbrainHelper sharedInstance] partnerKey];


    //  XCTAssertTrue([Outbrain _saveUserTokenInKeychain:token], @"Should be able to save to keychain");
    //  XCTAssertNotNil([Outbrain _getUserTokenFromKeychainIfAvailable], @"User token should be saved in keychain");
    //  XCTAssertTrue([token isEqualToString:[Outbrain _getUserTokenFromKeychainIfAvailable]], @"Keychain token should equal property");
}



@end
