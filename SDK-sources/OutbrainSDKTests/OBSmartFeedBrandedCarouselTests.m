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

- (void)testSmartFeedResponseSettings {
    OBSettings *settings = self.responseParent.settings;
    XCTAssertTrue([settings.recMode isEqualToString:@"odb_dynamic_ad-carousel"]);
    OBBrandedCarouselSettings *brandedCarouselSettings = settings.brandedCarouselSettings;
    XCTAssertNotNil(brandedCarouselSettings);
    XCTAssertTrue([brandedCarouselSettings.carouselTitle isEqualToString:@"COVID-19 Mythbusters: Get the Facts"]);
    XCTAssertTrue([brandedCarouselSettings.carouselSponsor isEqualToString:@"Outbrain"]);
    XCTAssertTrue([brandedCarouselSettings.carouselType isEqualToString:@"Carousel"]);
    XCTAssertTrue([brandedCarouselSettings.image.url.absoluteString isEqualToString:@"https://images.outbrainimg.com/transform/v3/eyJpdSI6IjM0ZGI3YzFhYWZhNTZjOTU0MjY4MmU0ZTVhMzdlNDQ3NWExZmY0NzlmNDZhYWI4NjEzMjdjMDBjZTEwOWIyYzEiLCJ3Ijo0MiwiaCI6NDIsImQiOjEuNSwiY3MiOjAsImYiOjR9.webp"]);
    XCTAssertTrue([brandedCarouselSettings.carouselClickUrl.absoluteString isEqualToString:@"https://paid.outbrain.com/network/redir?p=TV-jqloioZ5gh9rbmhG_8hGi5SyowVGcgT7q1Mmv264LQJS9JQOgk6lGNxlypgykkS7o2iFV2kIjj4ErjCTovw9dd8o4o43t32YI1SAoTALOKp-ooeVJ8uoXi3Cov7x93uF9mG1YgwxImNytvcqAeoCcrcmHM18-bzKDl4gqZQGlBMOtw9fnBidXa5Nvp7K6FjEYZ_nZWxPl3vsxYTj4z57FI995Qbht1tY39Y3cXpYpYUiQPGjjp8C4ibSXVrzWQnyiojQAXiiStmlVGFp19q2KdhQIcOgiwn6stlxhcBhXsqSzXvK8YcAKrLqEushl1egiedldXLr3O_WK1HECNamxa6zJUBxMzLBbzZF8FAGhRc7WsJWztd4effXQLs6AnvCevaaI_jRfiMAblUUySHQCmBCATz8VMIiag21rDpsmyun39JH0Jaipvvhs57qFiZ1jGh-NW17Wr8Yd3-bf2rJTwQfjGePO0_1yZp4V1yk3NRaXIF33pn9L7Grwk-W_onwU3jor665IdDE56wv7hwvA2FG9yDtiwmh6u0kG5exrvDKjp58HfI1VKFuD2Cn6tIkbi40aajjZ55fg6-kwSITtxWMy5Gwv7KExU-DAmQT2IB8CuWOragsn_-OurCqfQGvwnnQL29ODv-qD-VqreIitC-joleO8x1J2Au2BeHgwlwsisr6ZBkyVjpf-4b4PrSomeSWn2OvZpD9RRsu6PXI-Jj4UPvd945y__iVR_HT0NLRC7GVTI5-33SKw7wko3-s49xyIYxoRlaiRzMklgUqeyssz3zxgMbOekkcHcnM&c=579a87f7&v=3"]);
    
}

- (void)testParentSFItemParsing {
    NSArray *parentItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(parentItems.count, 1);
    
    SFItemData *sfItem = parentItems[0];
    XCTAssertEqual(sfItem.itemType, SFTypeBrandedCarouselWithTitle);
    XCTAssertNil(sfItem.singleRec);
    XCTAssertNotNil(sfItem.outbrainRecs);
    XCTAssertTrue([sfItem.widgetId isEqualToString:@"BCR_1"]);
    OBRecommendation *singleRec = sfItem.outbrainRecs[0];
    XCTAssertTrue([singleRec.content isEqualToString:@"Fact: Coronavirus Can Be Transmitted in Hot Climates"]);
    XCTAssertTrue([singleRec.ctaText isEqualToString:@"Learn More"]);
    
}

@end
