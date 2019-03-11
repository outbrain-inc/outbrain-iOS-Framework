//
//  MultivacResponseTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 11/03/2019.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"
#import "OBMultivacRequestOperation.h"

@class OBMultivacRequestOperation;

@interface OBMultivacRequestOperation (Testing)

- (void) parseResponseData:(NSData *)responseData;
- (instancetype)initWithRequest:(OBRequest *)request;

@property (nonatomic, strong) NSDate *requestStartDate;

@end


@interface MultivacResponseTests : XCTestCase <MultivacResponseDelegate>

@property (nonatomic, strong) OBMultivacRequestOperation *operation;
@property (nonatomic, strong) SmartFeedManager *smartFeedManager;
@property (nonatomic, strong) NSData *jsonData;

@property (nonatomic, strong) XCTestExpectation *expectation;

@end


@implementation MultivacResponseTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForResource:@"outbrain_multivac_response" ofType:@"json"];
    self.jsonData = [NSData dataWithContentsOfFile:path];
    
    XCTAssertNotNil(self.jsonData);
    
    self.operation = [[OBMultivacRequestOperation alloc] initWithRequest:[self generateMultivacRequest]];
    self.operation.multivacDelegate = self;
    self.operation.requestStartDate = [NSDate date];
    self.expectation = [self expectationWithDescription:@"Multivac callback"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testParseMultivacResponse {
    [self.operation parseResponseData:self.jsonData];
    [self waitForExpectations:@[self.expectation] timeout:2];
}

#pragma mark - Private methods

-(OBRequest *) generateMultivacRequest {
    NSString *url = @"http://mobile-demo.outbrain.com/2013/12/15/test-page-2";
    OBRequest *request = [OBRequest requestWithURL:url widgetID:@"SFD_MAIN_2" widgetIndex:1];
    request.lastCardIdx = 0;
    request.lastIdx = 0;
    request.isMultivac = YES;
    return request;
}

#pragma mark - MultivacResponseDelegate

- (void)onMultivacSuccess:(NSArray<OBRecommendationResponse *> *)cardsResponseArray feedIdx:(NSInteger)feedIdx hasMore:(BOOL)hasMore {
    [self.expectation fulfill];
    XCTAssertTrue(hasMore);
    XCTAssertEqual(1, feedIdx);
    XCTAssertEqual(3, [cardsResponseArray count]);
    
    [self verifyCard0:cardsResponseArray[0]];
    [self verifyCard1:cardsResponseArray[1]];
    [self verifyCard2:cardsResponseArray[2]];
}

- (void)onMultivacFailure:(NSError *)error {
    
}

-(void) verifyCard0:(OBRecommendationResponse *)recsResponse {
    XCTAssert([@"MV80Y2NjMjM0MDk2OGU1MTFlY2QxYzZmNTJmMWUzOWFhN18w" isEqualToString:recsResponse.responseRequest.token]);
    NSString *reqId = [recsResponse.responseRequest getStringValueForPayloadKey:@"req_id"];
    XCTAssert([@"804d8988ed7a0d8072663612153cdac8" isEqualToString:reqId]);
    XCTAssertEqual(1, [recsResponse.recommendations count]);
    OBRecommendation *rec = recsResponse.recommendations[0];
    XCTAssert([@"Marcus Smart sets up Gordon Hayward with a deft behind-the-back assist as Celtics hammer Warriors" isEqualToString: [rec content]]);
}

-(void) verifyCard1:(OBRecommendationResponse *)recsResponse {
    XCTAssert([@"MV80Y2NjMjM0MDk2OGU1MTFlY2QxYzZmNTJmMWUzOWFhN18w" isEqualToString:recsResponse.responseRequest.token]);
    NSString *reqId = [recsResponse.responseRequest getStringValueForPayloadKey:@"req_id"];
    XCTAssert([@"d7d0197f6460f8f88e267a3fc98fcba4" isEqualToString:reqId]);
    XCTAssertEqual(2, [recsResponse.recommendations count]);
    OBRecommendation *rec = recsResponse.recommendations[1];
    XCTAssert([@"Rennes vs Arsenal preview: Alexandre Lacazette suspended for Europa League last-16 tie" isEqualToString: [rec content]]);
}

-(void) verifyCard2:(OBRecommendationResponse *)recsResponse {
    XCTAssert([@"MV80Y2NjMjM0MDk2OGU1MTFlY2QxYzZmNTJmMWUzOWFhN18w" isEqualToString:recsResponse.responseRequest.token]);
    NSString *reqId = [recsResponse.responseRequest getStringValueForPayloadKey:@"req_id"];
    XCTAssert([@"4a39c90fe96018663c8d25f4939fc0a0" isEqualToString:reqId]);
    XCTAssertEqual(1, [recsResponse.recommendations count]);
    OBRecommendation *rec = recsResponse.recommendations[0];
    XCTAssert([@"Deadly Cold: 22 Photos Capture Life-Threatening Frozen Weather" isEqualToString: [rec content]]);
}


@end
