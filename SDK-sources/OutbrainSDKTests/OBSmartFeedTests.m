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
#import "SFUtils.h"

@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end

@interface SmartFeedManager (Testing)

-(NSArray *) createSmartfeedItemsArrayFromResponse:(OBRecommendationResponse *)response;

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath;

-(BOOL) isVideoIncludedInResponse:(OBRecommendationResponse *)response;

-(NSURL *) appendParamsToVideoUrl:(OBRecommendationResponse *)response;

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

- (void)testSmartFeedResponsesVidSettings {
    XCTAssertTrue([[self.responseParent.responseRequest getStringValueForPayloadKey:@"vid"] integerValue] == 1);
    XCTAssertFalse([[self.responseChild1.responseRequest getStringValueForPayloadKey:@"vid"] integerValue] == 1);
}

- (void)testSmartFeedResponsesVideoUrl {
    XCTAssertTrue([self.responseParent.settings.videoUrl.absoluteString isEqualToString:@"https://static-test.outbrain.com/video/app/vidgetInApp.html?widgetId=AR_1&publisherId=111&sourceId=222"]);
    XCTAssertNil(self.responseChild1.settings.videoUrl);
}

- (void)testSmartFeedVideoUrlWithParams {
    XCTAssertTrue([self.responseParent.settings.videoUrl.absoluteString isEqualToString:@"https://static-test.outbrain.com/video/app/vidgetInApp.html?widgetId=AR_1&publisherId=111&sourceId=222"]);
    
    NSURL *videoUrlWithParams = [self.smartFeedManager appendParamsToVideoUrl:self.responseParent];
    NSArray *queryItems = [[[NSURLComponents alloc] initWithURL:videoUrlWithParams resolvingAgainstBaseURL:nil] queryItems];
    NSLog(@"videoUrlWithParams.absoluteString: %@", videoUrlWithParams.absoluteString);
    
    XCTAssertNotNil([OBTestUtils valueForKey:@"platform" fromQueryItems:queryItems]);
    XCTAssertNotNil([OBTestUtils valueForKey:@"inApp" fromQueryItems:queryItems]);
    XCTAssertNotNil([OBTestUtils valueForKey:@"deviceIfa" fromQueryItems:queryItems]);
}

- (void)testSmartFeedResponsesVideoIsIncluded {
    XCTAssertTrue([self.smartFeedManager isVideoIncludedInResponse:self.responseParent]);
    XCTAssertFalse([self.smartFeedManager isVideoIncludedInResponse:self.responseChild1]);
    XCTAssertFalse([self.smartFeedManager isVideoIncludedInResponse:self.responseChild2]);
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
    XCTAssertNil(self.responseChild3.settings.feedContentArray);
}

- (void)testFeedCycleLimitIsFetchedCorrectlyFromResponse {
    XCTAssertEqual(self.responseParent.settings.feedCyclesLimit, 5);
    XCTAssertEqual(self.responseChild1.settings.feedCyclesLimit, 0);
}

- (void)testPublisherLogoIsFetchedCorrectlyFromResponse {
    OBRecommendation *recWithLogo = self.responseChild1.recommendations[0];
    XCTAssertTrue([recWithLogo.publisherLogoImage.url.absoluteString isEqualToString:@"https://images.outbrainimg.com/transform/v3/eyJpdSI6ImY5OTE5OTIxMTg5YTNlOThlMDFiMjE3NjQxOTg0ZDcwOGY5ZWU1ZmY5YWFhM2I4YmRhZmZmNjQ3MmIzZDljOTQiLCJ3Ijo4NSwiaCI6MjAsImQiOjIuMCwiY3MiOjAsImYiOjB9.jpg"]);
    
    OBRecommendation *recNoLogo = self.responseChild3.recommendations[0];
    XCTAssertNil(recNoLogo.publisherLogoImage);
    
}

- (void)testSmartfeedShadowColorFromResponse {
    XCTAssertTrue([self.responseParent.settings.smartfeedShadowColor isEqualToString:@"#ffa500"]);
    XCTAssertNil(self.responseChild1.settings.smartfeedShadowColor);
    XCTAssertNil(self.responseChild2.settings.smartfeedShadowColor);
}

- (void)testSmartFeedManagerBuildArrayOfItems {
    NSArray *newItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(newItems.count, 3);
    
    newItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseChild1];
    XCTAssertEqual(newItems.count, 1);
    
    newItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseChild2];
    XCTAssertEqual(newItems.count, 2);
    
    newItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseChild3];
    XCTAssertEqual(newItems.count, 1);
}

-(void) testSingleTemplateNib {
    SFCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    [self verifyCollectionCellBasicOutlets:cell];

    
    SFTableViewCell *tableCell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFTableViewCell" owner:nil options:nil] objectAtIndex:0];
    [self verifyTableCellBasicOutlets:tableCell];
}

-(void) testSingleItemInHorizontalViewTemplateNib {
    SFCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalFixedItemCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellBasicOutlets:cell];
    
    
    cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalItemCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellBasicOutlets:cell];
}

-(void) testSingleWithTitleTemplateNib {
    SFCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleWithTitleCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellWithTitleOutlets:cell];
    
    
    SFTableViewCell *tableCell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleWithTitleTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyTableCellWithTitleOutlets:tableCell];
}

-(void) testSingleWithThumbnailImageTemplateNib {
    SFCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleWithThumbnailWithTitleCollectionCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellWithTitleOutlets:cell];
    
    cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleWithThumbnailCollectionCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellBasicOutlets:cell];
    
    
    SFTableViewCell *tableCell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleWithThumbnailWithTitleTableCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyTableCellWithTitleOutlets:tableCell];
    
    tableCell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleWithThumbnailTableCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyTableCellBasicOutlets:tableCell];
}

-(void) testVideoWithTitleTemplateNib {
    SFCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleVideoWithTitleCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellWithTitleOutlets:cell];
    
    SFTableViewCell *tableCell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleVideoWithTitleTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyTableCellWithTitleOutlets:tableCell];
}

-(void) testVideoNoTitleTemplateNib {
    SFCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleVideoNoTitleCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyCollectionCellBasicOutlets:cell];
    
    SFTableViewCell *tableCell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFSingleVideoNoTitleTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    [self verifyTableCellBasicOutlets:tableCell];
}

-(void) testSourceFormat {
    XCTAssertTrue([self.responseChild3.settings.sourceFormat isEqualToString:@"Recommended by $SOURCE"]);
    OBRecommendation *firstRecOfChild3 = self.responseChild3.recommendations[0];
    OBRecommendation *firstRecOfChild2 = self.responseChild2.recommendations[0];
    XCTAssertTrue(
                  [[SFUtils getRecSourceText:firstRecOfChild3.source withSourceFormat:self.responseChild3.settings.sourceFormat]
                  isEqualToString:[@"Recommended by " stringByAppendingString:firstRecOfChild3.source]]
                  );
    XCTAssertTrue(
                  [[SFUtils getRecSourceText:firstRecOfChild2.source withSourceFormat:self.responseChild2.settings.sourceFormat]
                   isEqualToString:firstRecOfChild2.source]
                  );
}


#pragma mark - utilities methods
-(void) verifyCollectionCellBasicOutlets:(SFCollectionViewCell *)cell {
    XCTAssertNotNil(cell.publisherLogo);
    XCTAssertNotNil(cell.publisherLogoHeight);
    XCTAssertNotNil(cell.publisherLogoWidth);
    XCTAssertNotNil(cell.recSourceLabel);
    XCTAssertNotNil(cell.recImageView);
    XCTAssertNotNil(cell.recTitleLabel);
    XCTAssertNotNil(cell.adChoicesButton);
}

-(void) verifyCollectionCellWithTitleOutlets:(SFCollectionViewCell *)cell {
    [self verifyCollectionCellBasicOutlets:cell];
    XCTAssertNotNil(cell.cardContentView);
    XCTAssertNotNil(cell.cellTitleLabel);
    XCTAssertNotNil(cell.outbrainLabelingContainer);
    XCTAssertNotNil(cell.outbrainLabelingContainer);
}

-(void) verifyTableCellBasicOutlets:(SFTableViewCell *)cell {
    XCTAssertNotNil(cell.publisherLogo);
    XCTAssertNotNil(cell.publisherLogoHeight);
    XCTAssertNotNil(cell.publisherLogoWidth);
    XCTAssertNotNil(cell.recSourceLabel);
    XCTAssertNotNil(cell.recImageView);
    XCTAssertNotNil(cell.recTitleLabel);
    XCTAssertNotNil(cell.adChoicesButton);
}

-(void) verifyTableCellWithTitleOutlets:(SFTableViewCell *)cell {
    [self verifyTableCellBasicOutlets:cell];
    XCTAssertNotNil(cell.cardContentView);
    XCTAssertNotNil(cell.cellTitleLabel);
    XCTAssertNotNil(cell.outbrainLabelingContainer);
    XCTAssertNotNil(cell.outbrainLabelingContainer);
}

@end
