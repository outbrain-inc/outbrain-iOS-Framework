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
#import "SFItemData.h"


@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end

@interface SmartFeedManager (Testing)

-(NSUInteger) addNewItemsToSmartFeedArray:(OBRecommendationResponse *)response;

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath;

@end

@interface OBSmartFeedTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *responseParent;
@property (nonatomic, strong) OBRecommendationResponse *responseChild1;
@property (nonatomic, strong) OBRecommendationResponse *responseChild2;
@property (nonatomic, strong) OBRecommendationResponse *responseChild3;

@property (nonatomic, strong) SmartFeedManager *smartFeedManager;

@end



@implementation OBSmartFeedTests

- (void)setUp {
    [super setUp];
    self.smartFeedManager = [[SmartFeedManager alloc] init];
    
    OBRecommendationRequestOperation *operation = [[OBRecommendationRequestOperation alloc] init];
    
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    NSDictionary *responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_parent"];
    XCTAssertNotNil(responseJson);
    self.responseParent = [operation createResponseWithDict:responseJson withError:nil];
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_child1"];
    XCTAssertNotNil(responseJson);
    self.responseChild1 = [operation createResponseWithDict:responseJson withError:nil];
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_child2"];
    XCTAssertNotNil(responseJson);
    self.responseChild2 = [operation createResponseWithDict:responseJson withError:nil];
    
    responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_child3"];
    XCTAssertNotNil(responseJson);
    self.responseChild3 = [operation createResponseWithDict:responseJson withError:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSmartFeedResponsesContent {
    XCTAssertEqual(self.responseParent.recommendations.count, 6);
    XCTAssertEqual(self.responseChild1.recommendations.count, 1);
    XCTAssertEqual(self.responseChild2.recommendations.count, 2);
    XCTAssertEqual(self.responseChild3.recommendations.count, 1);
}

- (void)testRecModeIsFetchedCorrectlyFromResponse {
    XCTAssertTrue([self.responseParent.settings.recMode isEqualToString:@"sdk_sfd_2_columns"]);
    XCTAssertTrue([self.responseChild1.settings.recMode isEqualToString:@"sdk_sfd_1_column"]);
    XCTAssertTrue([self.responseChild2.settings.recMode isEqualToString:@"sdk_sfd_thumbnails"]);
    XCTAssertTrue([self.responseChild3.settings.recMode isEqualToString:@"sdk_sfd_1_column"]);
}

- (void)testWidgetHeaderTextIsFetchedCorrectlyFromResponse {
    XCTAssertTrue([self.responseParent.settings.widgetHeaderText isEqualToString:@"Sponsored Links"]);
    XCTAssertTrue([self.responseChild1.settings.widgetHeaderText isEqualToString:@"Around CNN"]);
    XCTAssertNil(self.responseChild2.settings.widgetHeaderText);
    XCTAssertTrue([self.responseChild3.settings.widgetHeaderText isEqualToString:@"Sponsored Links"]);
}

- (void)testFeedContentIsFetchedCorrectlyFromResponse {
    XCTAssertNotNil(self.responseParent.settings.feedContentArray);
    XCTAssertEqual(self.responseParent.settings.feedContentArray.count, 3);
    XCTAssertTrue([self.responseParent.settings.feedContentArray[1] isEqualToString:@"SDK_SFD_2"]);
}

- (void)testFeedCycleLimitIsFetchedCorrectlyFromResponse {
    XCTAssertEqual(self.responseParent.settings.feedCyclesLimit, 5);
    XCTAssertEqual(self.responseChild1.settings.feedCyclesLimit, 0);
}

- (void)testSmartFeedManagerBuildArrayOfItems {
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseParent];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 3);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseChild1];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 4);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseChild2];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 6);
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseChild3];
    XCTAssertEqual(self.smartFeedManager.smartFeedItemsArray.count, 7);
}

- (void)testUITemplateIsSetCorrectly {
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseParent];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseChild1];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseChild2];
    [self.smartFeedManager addNewItemsToSmartFeedArray:self.responseChild3];
    
    SFItemData *sfItem = self.smartFeedManager.smartFeedItemsArray[0];
}


@end
