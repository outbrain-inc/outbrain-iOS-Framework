//
//  OBSmartFeedBrandedCarouselTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 25/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"
#import "OBRecommendationRequestOperation.h"
#import "SFItemData.h"
#import "SFUtils.h"

@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end

@interface SmartFeedManager (Testing)

-(NSArray *) createSmartfeedItemsArrayFromResponse:(OBRecommendationResponse *)response;

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath;

@end

@interface OBSmartFeedBrandedCarouselTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *responseParent;
@property (nonatomic, strong) SmartFeedManager *smartFeedManager;

@end

@implementation OBSmartFeedBrandedCarouselTests

- (void)setUp {
    [super setUp];
    self.smartFeedManager = [[SmartFeedManager alloc] init];
    
    OBRecommendationRequestOperation *operation = [[OBRecommendationRequestOperation alloc] init];
    
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    NSDictionary *responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_branded_carousel"];
    XCTAssertNotNil(responseJson);
    self.responseParent = [operation createResponseWithDict:responseJson withError:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSmartFeedResponsesSettings {
    OBSettings *settings = self.responseParent.settings;
    XCTAssertTrue([settings.recMode isEqualToString:@"odb_dynamic_ad-carousel"]);
}

- (void)testParentSFItemParsing {
    NSArray *parentItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(parentItems.count, 1);
    
    SFItemData *sfItem = parentItems[0];
    XCTAssertEqual(sfItem.itemType, SFTypeBrandedCarouselWithTitle);
    XCTAssertNil(sfItem.singleRec);
    XCTAssertNotNil(sfItem.outbrainRecs);
    XCTAssertTrue([sfItem.widgetId isEqualToString:@"BCR_1"]);
}

@end
