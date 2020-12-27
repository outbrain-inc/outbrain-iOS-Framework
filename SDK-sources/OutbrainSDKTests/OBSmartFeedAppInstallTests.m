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

@interface OBSmartFeedAppInstallTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *responseParent;
@property (nonatomic, strong) SmartFeedManager *smartFeedManager;

@end

@implementation OBSmartFeedAppInstallTests

- (void)setUp {
    [super setUp];
    self.smartFeedManager = [[SmartFeedManager alloc] init];
    
    OBRecommendationRequestOperation *operation = [[OBRecommendationRequestOperation alloc] init];
    
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    NSDictionary *responseJson = [OBTestUtils JSONFromFile: @"smart_feed_response_app_install_card"];
    XCTAssertNotNil(responseJson);
    self.responseParent = [operation createResponseWithDict:responseJson withError:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSmartFeedResponseSettings {
    OBSettings *settings = self.responseParent.settings;
    XCTAssertTrue([settings.recMode isEqualToString:@"odb_dynamic_ad-carousel"]);
    OBBrandedCarouselSettings *brandedCarouselSettings = settings.brandedCarouselSettings;
    XCTAssertNotNil(brandedCarouselSettings);
    XCTAssertNil(brandedCarouselSettings.carouselTitle);
    XCTAssertTrue([brandedCarouselSettings.carouselSponsor isEqualToString:@"YAHTZEE Rating Apps"]);
    XCTAssertTrue([brandedCarouselSettings.carouselType isEqualToString:@"AppInstall"]);
    XCTAssertTrue([brandedCarouselSettings.image.url.absoluteString isEqualToString:@"https://images.outbrainimg.com/transform/v3/eyJpdSI6IjgzYWMxOTM5YTZlNDdkMGUwYWU1ZWY3NDZjMTZhNTg1YmM1ZmMzZDc4MDUxZDc5N2ZlZTM1NzI5Nzg2NmFlNjMiLCJ3Ijo0MiwiaCI6NDIsImQiOjEuNSwiY3MiOjAsImYiOjB9.jpg"]);
}

- (void)testParentSFItemParsing {
    NSArray *parentItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(parentItems.count, 1);
    SFItemData *sfItem = parentItems[0];
    XCTAssertEqual(sfItem.itemType, SFTypeStripAppInstall);
    XCTAssertNotNil(sfItem.singleRec);
    XCTAssertNil(sfItem.outbrainRecs);
    XCTAssertTrue([sfItem.widgetId isEqualToString:@"SFD_BCR_1"]);
    OBRecommendation *singleRec = sfItem.singleRec;
    XCTAssertTrue([singleRec.content isEqualToString:@"Build an empire & travel through the ages!"]);
    XCTAssertNil(singleRec.ctaText);
    
}

@end
