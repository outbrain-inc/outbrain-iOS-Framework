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
    XCTAssert(rec.disclosure != nil);
    XCTAssert(rec.disclosure.clickUrl != nil);
    XCTAssert(rec.disclosure.imageUrl != nil);
}

- (void)testNormalNonRTBRecommendation {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"non_rtb_rec"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"From the Grapevine"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssert(rec.disclosure == nil);
}

- (void)testNormalRTBRecommendationNoClickUrl {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_no_disclosure_click_url"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssert(rec.disclosure == nil);
}

- (void)testNormalRTBRecommendationDiscImage {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_disclosure_empty_values"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssert(rec.disclosure == nil);
}

- (void)testNormalRTBRecommendationWithEmptyDisclosureValues {
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"rtb_rec_with_no_disclosure_image"];
    XCTAssertNotNil(recJson);
    OBRecommendation *rec = [OBRecommendation contentWithPayload:recJson];
    XCTAssert([rec.source isEqualToString:@"Zoom"]); // sanity
    XCTAssert(rec.isRTB == NO);
    XCTAssert(rec.shouldDisplayDisclosureIcon == NO);
    XCTAssert(rec.disclosure == nil);
}


@end
