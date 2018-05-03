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

@interface SmartFeedManager (Testing)

-(NSUInteger) addNewItemsToSmartFeedArray:(OBRecommendationResponse *)response;

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath;

@end

@interface OBSmartFeedTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *response1;
@property (nonatomic, strong) OBRecommendationResponse *response2;
@property (nonatomic, strong) OBRecommendationResponse *response3;
@property (nonatomic, strong) OBRecommendationResponse *response4;
@property (nonatomic, strong) OBRecommendationResponse *response5;

@property (nonatomic, strong) SmartFeedManager *smartFeedManager;

@end



@implementation OBSmartFeedTests

- (void)setUp {
    [super setUp];
    self.smartFeedManager = [[SmartFeedManager alloc] init];
    
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
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_4"];
    XCTAssertNotNil(responseJson);
    self.response4 = [operation createResponseWithDict:responseJson withError:nil];
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_5"];
    XCTAssertNotNil(responseJson);
    self.response5 = [operation createResponseWithDict:responseJson withError:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSmartFeedResponsesContent {
    XCTAssertEqual(self.response1.recommendations.count, 6);
    XCTAssertEqual(self.response2.recommendations.count, 2); // paid
    XCTAssertEqual(self.response3.recommendations.count, 4); // organic
    XCTAssertEqual(self.response4.recommendations.count, 2); // paid
    XCTAssertEqual(self.response5.recommendations.count, 4); // organic
}

- (void)testSmartFeedManagerBuildArrayOfItems {
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response1];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 5);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response2];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 7);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response3];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 8);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response4];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 10);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response5];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 11);
}

- (void)testHorizontalCellsAreBuiltForOrganicRecs {
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response1];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response2];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response3];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response4];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.response5];
    
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:0 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:1 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:2 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:3 inSection:1]]);
    XCTAssertTrue([self.smartFeedManager  isHorizontalCell:[NSIndexPath indexPathForRow:4 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:5 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:6 inSection:1]]);
    XCTAssertTrue([self.smartFeedManager  isHorizontalCell:[NSIndexPath indexPathForRow:7 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:8 inSection:1]]);
    XCTAssertFalse([self.smartFeedManager isHorizontalCell:[NSIndexPath indexPathForRow:9 inSection:1]]);
    XCTAssertTrue([self.smartFeedManager  isHorizontalCell:[NSIndexPath indexPathForRow:10 inSection:1]]);
}


@end
