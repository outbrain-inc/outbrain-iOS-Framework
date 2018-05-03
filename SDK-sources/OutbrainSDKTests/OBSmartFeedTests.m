//
//  OBSmartFeedTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 03/05/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"
#import "OBRecommendationRequestOperation.h"

@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end


@interface OBSmartFeedTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *response1;
@property (nonatomic, strong) OBRecommendationResponse *response2;
@property (nonatomic, strong) OBRecommendationResponse *response3;

@end



@implementation OBSmartFeedTests

- (void)setUp {
    [super setUp];
    OBRecommendationRequestOperation *operation = [[OBRecommendationRequestOperation alloc] init];
    
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    NSDictionary *responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_1"];
    XCTAssertNotNil(responseJson);
    self.response1 = [operation createResponseWithDict:responseJson withError:nil];
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_2"];
    XCTAssertNotNil(responseJson);
    self.response2 = [operation createResponseWithDict:responseJson withError:nil];
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_3"];
    XCTAssertNotNil(responseJson);
    self.response3 = [operation createResponseWithDict:responseJson withError:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSmartFeedResponses {
    XCTAssertEqual(self.response1.recommendations.count, 6);
    XCTAssertEqual(self.response2.recommendations.count, 2);
    XCTAssertEqual(self.response3.recommendations.count, 4);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
