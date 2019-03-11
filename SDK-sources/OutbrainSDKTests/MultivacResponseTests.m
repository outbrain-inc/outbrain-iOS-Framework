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
    OBRecommendationResponse *recsResponse0 = cardsResponseArray[0];
    XCTAssert([@"MV80Y2NjMjM0MDk2OGU1MTFlY2QxYzZmNTJmMWUzOWFhN18w" isEqualToString:recsResponse0.responseRequest.token]);
    NSString *reqId = [recsResponse0.responseRequest getStringValueForPayloadKey:@"req_id"];
    XCTAssert([@"804d8988ed7a0d8072663612153cdac8" isEqualToString:reqId]);
    XCTAssertEqual(1, [recsResponse0.recommendations count]);
    OBRecommendation *rec0 = recsResponse0.recommendations[0];
    XCTAssert([@"Marcus Smart sets up Gordon Hayward with a deft behind-the-back assist as Celtics hammer Warriors" isEqualToString: [rec0 content]]);
}

- (void)onMultivacFailure:(NSError *)error {
    
}


@end
