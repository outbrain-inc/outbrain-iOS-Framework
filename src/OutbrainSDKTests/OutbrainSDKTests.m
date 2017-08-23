//
//  OutbrainSDKTests.m
//  OutbrainSDKTests
//
//  Created by Joseph Ridenour on 12/9/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OutbrainSDK.h"
#import "Outbrain_Private.h"


@interface OutbrainSDKTests : XCTestCase
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





@end
