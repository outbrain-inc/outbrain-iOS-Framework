//
//  OBRecRTBTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 18/06/2018.
//  Copyright © 2022 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"

@interface OBResponseRequest (Testing)

- (instancetype)initWithPayload:(NSDictionary *)aPayload;

@end


@interface OBResponseRequestTests : XCTestCase


@end

@implementation OBResponseRequestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testOptOutFalseBool {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"response_request_oo_false_bool"];
    XCTAssertNotNil(recJson);
    OBResponseRequest *responseRequest = [[OBResponseRequest alloc] initWithPayload:[recJson valueForKey:@"request"]];
    XCTAssertFalse(responseRequest.optedOut);
}

- (void)testOptOutFalseString {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"response_request_oo_false_string"];
    XCTAssertNotNil(recJson);
    OBResponseRequest *responseRequest = [[OBResponseRequest alloc] initWithPayload:[recJson valueForKey:@"request"]];
    XCTAssertFalse(responseRequest.optedOut);
}

- (void)testOptOutTrueBool {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"response_request_oo_true_bool"];
    XCTAssertNotNil(recJson);
    OBResponseRequest *responseRequest = [[OBResponseRequest alloc] initWithPayload:[recJson valueForKey:@"request"]];
    XCTAssertTrue(responseRequest.optedOut);
}

- (void)testOptOutTrueString {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"response_request_oo_true_string"];
    XCTAssertNotNil(recJson);
    OBResponseRequest *responseRequest = [[OBResponseRequest alloc] initWithPayload:[recJson valueForKey:@"request"]];
    XCTAssertTrue(responseRequest.optedOut);
}

- (void)testOptOutMissing {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"response_request_oo_missing"];
    XCTAssertNotNil(recJson);
    OBResponseRequest *responseRequest = [[OBResponseRequest alloc] initWithPayload:[recJson valueForKey:@"request"]];
    XCTAssertFalse(responseRequest.optedOut); // default is false
}


@end
