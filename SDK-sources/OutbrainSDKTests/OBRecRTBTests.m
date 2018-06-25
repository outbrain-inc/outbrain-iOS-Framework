//
//  OBRecRTBTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 18/06/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"

@interface OBRecommendation (Testing)

+ (instancetype)contentWithPayload:(NSDictionary *)payload;

@end


@interface OBRecRTBTests : XCTestCase


@end

@implementation OBRecRTBTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNormalRTBRecommendation {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_disclosure"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == YES);
    XCTAssert(rec.shouldDisplayDisclosureIcon == YES);
    XCTAssertNotNil(rec.disclosure);
    XCTAssertNotNil(rec.disclosure.clickUrl);
    XCTAssertNotNil(rec.disclosure.imageUrl);
    XCTAssertNotNil(rec.pixels);
}

- (void)testNormalNonRTBRecommendation {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"non_rtb_rec"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"From the Grapevine"]); // sanity
    XCTAssertFalse(rec.isRTB);
    XCTAssertFalse(rec.shouldDisplayDisclosureIcon);
    XCTAssertNil(rec.disclosure);
    XCTAssertNil(rec.pixels);
}

- (void)testNormalRTBRecommendationNoClickUrl {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_no_disclosure_click_url"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssertNil(rec.disclosure);
}

- (void)testNormalRTBRecommendationWithEmptyDisclosureValues {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_disclosure_empty_values"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssert(rec.disclosure == nil);
}

- (void)testNormalRTBRecommendationNoDiscImage {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_no_disclosure_image"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssert(rec.disclosure == nil);
}


@end
