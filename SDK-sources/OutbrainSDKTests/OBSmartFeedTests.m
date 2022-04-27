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
#import "SFViewabilityService.h"


@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end

@interface SmartFeedManager (Testing)

-(NSArray *) createSmartfeedItemsArrayFromResponse:(OBRecommendationResponse *)response;

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath;

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath;

-(BOOL) isVideoIncludedInResponse:(OBRecommendationResponse *)response;

+(NSURL *) appendParamsToVideoUrl:(OBRecommendationResponse *)response url:(NSString *)url;

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
    XCTAssertTrue([@"https://libs.outbrain.com/video/app/vidgetInApp.html" isEqualToString:self.responseChild1.settings.videoUrl.absoluteString]);
}

- (void)testSmartFeedVideoUrlWithParams {
    XCTAssertTrue([self.responseParent.settings.videoUrl.absoluteString isEqualToString:@"https://static-test.outbrain.com/video/app/vidgetInApp.html?widgetId=AR_1&publisherId=111&sourceId=222"]);
    
    NSURL *videoUrlWithParams = [SFUtils appendParamsToVideoUrl:self.responseParent url:@"https://edition.cnn.com/2020/01/21/us/bronny-james-basketball-game-lebron-james-disappointed-spt-trnd/index.html"];
    
    NSArray *queryItems = [[[NSURLComponents alloc] initWithURL:videoUrlWithParams resolvingAgainstBaseURL:nil] queryItems];
    NSLog(@"videoUrlWithParams.absoluteString: %@", videoUrlWithParams.absoluteString);
    
    XCTAssertNotNil([OBTestUtils valueForKey:@"platform" fromQueryItems:queryItems]);
    XCTAssertNotNil([OBTestUtils valueForKey:@"inApp" fromQueryItems:queryItems]);
    XCTAssertNotNil([OBTestUtils valueForKey:@"deviceIfa" fromQueryItems:queryItems]);
    XCTAssertNotNil([OBTestUtils valueForKey:@"articleUrl" fromQueryItems:queryItems]);
}

- (void)testSmartFeedResponsesVideoIsIncluded {
    XCTAssertTrue([SFUtils isVideoIncludedInResponse:self.responseParent]);
    XCTAssertFalse([SFUtils isVideoIncludedInResponse:self.responseChild1]);
    XCTAssertFalse([SFUtils isVideoIncludedInResponse:self.responseChild2]);
}
    
- (void)testSmartFeedResponsesContent {
    XCTAssertEqual(self.responseParent.recommendations.count, 6);
    XCTAssertEqual(self.responseChild1.recommendations.count, 1);
    XCTAssertEqual(self.responseChild2.recommendations.count, 2);
    XCTAssertEqual(self.responseChild3.recommendations.count, 1);
}

- (void)testAbTestsOptimizationsSettingsFromParentResponse {
    XCTAssertEqual(self.responseParent.settings.abTitleFontSize, 14);
    XCTAssertEqual(self.responseParent.settings.abSourceFontSize, 12);
    XCTAssertEqual(self.responseParent.settings.abTitleFontStyle, 1);
    XCTAssertTrue([self.responseParent.settings.abSourceFontColor isEqualToString:@"#ffa511"]);
    XCTAssertTrue(self.responseParent.settings.abImageFadeAnimation);
    XCTAssertEqual(self.responseParent.settings.abImageFadeDuration, 400);
}

- (void)testAbTestsOptimizationsSettingsWhenResponseEmpty {
    XCTAssertEqual(self.responseChild1.settings.abTitleFontSize, 0);
    XCTAssertEqual(self.responseChild1.settings.abSourceFontSize, 0);
    XCTAssertEqual(self.responseChild1.settings.abTitleFontStyle, -1);
    XCTAssertNil(self.responseChild1.settings.abSourceFontColor);
    XCTAssertTrue(self.responseChild1.settings.abImageFadeAnimation);
    XCTAssertEqual(self.responseChild1.settings.abImageFadeDuration, 500);
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

- (void)testParentSFItemParsing {
    NSArray *parentItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(parentItems.count, 3);
    
    SFItemData *sfItemParentFirst = parentItems[0];
    XCTAssertEqual(sfItemParentFirst.itemType, SFTypeGridTwoInRowNoTitle);
    BOOL checkColors = CGColorEqualToColor(sfItemParentFirst.shadowColor.CGColor, [SFUtils colorFromHexString:@"#ffa500"].CGColor);
    XCTAssertTrue(checkColors);
    XCTAssertNil(sfItemParentFirst.singleRec);
    XCTAssertNotNil(sfItemParentFirst.outbrainRecs);
    XCTAssertTrue([sfItemParentFirst.widgetId isEqualToString:@"SFD_MAIN_2"]);
    OBRecommendation *singleRec = sfItemParentFirst.outbrainRecs[0];
    XCTAssertTrue([singleRec.content isEqualToString:@"How To Start Ecommerce As A Side Income"]);
}

- (void) testSFViewabilityConfigureViewabilityPerListingForCell {
    NSArray *parentItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(parentItems.count, 3);
    SFItemData *sfItemParentFirst = parentItems[0];
    UICollectionViewCell *cell = [[UICollectionViewCell alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    
    [[SFViewabilityService sharedInstance] configureViewabilityPerListingForCell:cell withSFItem:sfItemParentFirst initializationTime:[NSDate date]];
    [[SFViewabilityService sharedInstance] configureViewabilityPerListingForCell:cell withSFItem:sfItemParentFirst initializationTime:[NSDate date]];
}

- (void) testSFViewabilityConfigureViewabilityPerListingForView {
    NSArray *parentItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseParent];
    XCTAssertEqual(parentItems.count, 3);
    SFItemData *sfItemParentFirst = parentItems[0];
    UIView *sampleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [[SFViewabilityService sharedInstance] configureViewabilityPerListingFor:sampleView withRec:sfItemParentFirst.outbrainRecs[0]];
}

- (void)testFirstChildSFItemParsing {
    NSArray *firstChildItems = [self.smartFeedManager createSmartfeedItemsArrayFromResponse:self.responseChild1];
    XCTAssertEqual(firstChildItems.count, 1);
    
    SFItemData *sfItem = firstChildItems[0];
    XCTAssertEqual(sfItem.itemType, SFTypeStripWithTitle);
    XCTAssertNil(sfItem.shadowColor);
    XCTAssertNotNil(sfItem.singleRec);
    XCTAssertNil(sfItem.outbrainRecs);
    XCTAssertTrue([sfItem.widgetId isEqualToString:@"SDK_SFD_1"]);
    OBRecommendation *singleRec = sfItem.singleRec;
    XCTAssertTrue([singleRec.content isEqualToString:@"Millwall set to complete record deal for Tom Bradshaw"]);
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

-(void) testTableViewHorizontalCellsWithTitleTemplateNib {
    SFHorizontalTableViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalFixedWithTitleTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    XCTAssertNotNil(cell.titleLabel);
    
    cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalFixedWithTitleWithVideoTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    XCTAssertNotNil(cell.titleLabel);
    
    cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalCarouselWithTitleTableViewCell" owner:nil options:nil] objectAtIndex:0];
    
    XCTAssertNotNil(cell.titleLabel);
}

-(void) testCollectionViewViewHorizontalCellsWithTitleTemplateNib {
    SFHorizontalCollectionViewCell *cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalFixedWithTitleCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    
    XCTAssertNotNil(cell.titleLabel);
    
    cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalCarouselWithTitleCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    
    XCTAssertNotNil(cell.titleLabel);
    
    cell = [[[NSBundle bundleForClass:[SmartFeedManager class]] loadNibNamed:@"SFHorizontalFixedWithTitleWithVideoCollectionViewCell" owner:nil options:nil] objectAtIndex:0];
    
    XCTAssertNotNil(cell.titleLabel);
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

-(void) testAudienceCampaignsLabel {
    OBRecommendation *rec = self.responseParent.recommendations[0];
    XCTAssertTrue([rec.audienceCampaignsLabel isEqualToString: @"sponsored"]);
    
    OBRecommendation *rec2 = self.responseParent.recommendations[1];
    XCTAssertNil(rec2.audienceCampaignsLabel);
}

-(void) testSourceFormatParsing {
    XCTAssertTrue([self.responseChild3.settings.paidSourceFormat isEqualToString:@"Provided to you by $SOURCE"]);
    XCTAssertTrue([self.responseChild3.settings.organicSourceFormat isEqualToString:@"Recommended by $SOURCE"]);
    
    XCTAssertTrue([self.responseChild2.settings.paidSourceFormat isEqualToString:@"Paid provider"]);
    XCTAssertTrue([self.responseChild2.settings.organicSourceFormat isEqualToString:@"Custom Organic Source"]);
}

-(void) testGetRecSourceTextWithSettingsForOrganicRec {
    OBRecommendation *testRec = self.responseChild2.recommendations[0];
    XCTAssertFalse(testRec.isPaidLink);
    
    
    // Organic with "Recommended by $SOURCE"
    OBSettings *testSettings = self.responseChild3.settings;
    XCTAssertTrue([testSettings.organicSourceFormat isEqualToString:@"Recommended by $SOURCE"]);
    NSString *sourceText = [SFUtils getSourceTextForRec:testRec withSettings:testSettings];
    XCTAssertTrue([sourceText isEqualToString:[@"Recommended by " stringByAppendingString:testRec.source]]);
    
    // Organic with "Custom Organic Source"
    testSettings = self.responseChild2.settings;
    XCTAssertTrue([testSettings.organicSourceFormat isEqualToString:@"Custom Organic Source"]);
    sourceText = [SFUtils getSourceTextForRec:testRec withSettings:testSettings];
    XCTAssertTrue([sourceText isEqualToString: @"Custom Organic Source"]);
    
    // Organic with "Custom Organic Source"
    testSettings = self.responseChild1.settings;
    XCTAssertNil(testSettings.organicSourceFormat);
    sourceText = [SFUtils getSourceTextForRec:testRec withSettings:testSettings];
    XCTAssertTrue([sourceText isEqualToString: testRec.source]);
}

-(void) testGetRecSourceTextWithSettingsForPaidRec {
    OBRecommendation *testRec = self.responseChild3.recommendations[0];
    XCTAssertTrue(testRec.isPaidLink);
    
    
    // Paid with "Recommended by $SOURCE"
    OBSettings *testSettings = self.responseChild3.settings;
    XCTAssertTrue([testSettings.paidSourceFormat isEqualToString:@"Provided to you by $SOURCE"]);
    NSString *sourceText = [SFUtils getSourceTextForRec:testRec withSettings:testSettings];
    XCTAssertTrue([sourceText isEqualToString:[@"Provided to you by " stringByAppendingString:testRec.source]]);
    
    // Paid with "Custom Organic Source"
    testSettings = self.responseChild2.settings;
    XCTAssertTrue([testSettings.paidSourceFormat isEqualToString:@"Paid provider"]);
    sourceText = [SFUtils getSourceTextForRec:testRec withSettings:testSettings];
    XCTAssertTrue([sourceText isEqualToString: @"Paid provider"]);
    
    // Paid with "Custom Organic Source"
    testSettings = self.responseChild1.settings;
    XCTAssertNil(testSettings.paidSourceFormat);
    sourceText = [SFUtils getSourceTextForRec:testRec withSettings:testSettings];
    XCTAssertTrue([sourceText isEqualToString: testRec.source]);
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
}

-(void) testSFItemDataChildWidget {
    NSArray *recommendations = self.responseChild1.recommendations;
    OBRecommendation *rec = recommendations[0];
    SFItemData *item = [[SFItemData alloc] initWithSingleRecommendation:rec
                                                                     odbResponse:self.responseChild1
                                                                            type:SFTypeStripWithTitle];
    XCTAssertTrue([item.widgetTitle isEqualToString: @"Around CNN"]);
    XCTAssertTrue([item.widgetId isEqualToString: @"SDK_SFD_1"]);
    XCTAssertTrue([item.requestId isEqualToString: @"c9b44236deaeda06b243b584e596e737"]);
}

-(void) testSFItemDataParentWidget {
    NSArray *recommendations = self.responseParent.recommendations;
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    NSRange subRange = NSMakeRange(0, 2);
    NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
    
    SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs
                                            odbResponse:self.responseParent
                                                   type:SFTypeGridTwoInRowNoTitle];
    
    XCTAssertEqual(item.outbrainRecs.count, 2);
    XCTAssertTrue([item.widgetId isEqualToString: @"SFD_MAIN_2"]);
    XCTAssertTrue([item.requestId isEqualToString: @"b4b6ea633069219626e103dc55da993c"]);
}
        
- (void)testSmartFeedImageType {
    NSArray *recommendations = self.responseChild1.recommendations;
    OBRecommendation *rec = recommendations[0];
    XCTAssertFalse(rec.image.isGif);
    
    recommendations = self.responseChild2.recommendations;
    rec = recommendations[0];
    XCTAssertFalse(rec.image.isGif);
    
    recommendations = self.responseChild3.recommendations;
    rec = recommendations[0];
    XCTAssertTrue(rec.image.isGif);
}

- (void)testReadMoreText {
    XCTAssertTrue([self.responseParent.settings.readMoreButtonText isEqualToString:@"Read More"]);
}


@end
