//
//  SmartFeedManager.m
//  ios-SmartFeed
//
//  Created by oded regev on 2/1/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SmartFeedManager.h"
#import "SFTableViewHeaderCell.h"
#import "SFCollectionViewHeaderCell.h"
#import "SFHorizontalCollectionViewCell.h"
#import "SFBrandedCarouselCollectionCell.h"
#import "SFHorizontalWithVideoCollectionViewCell.h"
#import "SFHorizontalWithVideoTableViewCell.h"
#import "SFCollectionViewCell.h"
#import "SFTableViewCell.h"
#import "SFDefaultCollectionViewDelegate.h"
#import "SFHorizontalTableViewCell.h"
#import "SFVideoCollectionViewCell.h"
#import "SFVideoTableViewCell.h"
#import "SFUtils.h"
#import "SFItemData.h"
#import "OBAppleAdIdUtil.h"
#import "OutbrainManager.h"
#import "SFImageLoader.h"
#import "SFCollectionViewManager.h"
#import "SFTableViewManager.h"
#import "OBViewabilityService.h"
#import "OBView.h"
#import "SFViewabilityService.h"
#import <OutbrainSDK/OutbrainSDK.h>
#import "MultivacResponseDelegate.h"
#import "SFDefaultDelegate.h"

@interface SmartFeedManager() <SFPrivateEventListener, WKUIDelegate, MultivacResponseDelegate>

@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) NSString * _Nullable widgetId;

@property (nonatomic, assign) NSInteger lastCardIdx; // lastCardIdx is the index of the last “child widget” inside the smartfeed
@property (nonatomic, assign) NSInteger lastIdx;  // lastIdx is the index of the last widget on the page (because we can load widgets async)
@property (nonatomic, assign) BOOL hasMore;


@property (nonatomic, assign) BOOL isRTL;
@property (nonatomic, strong) NSString *fab;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isSmartfeedWithNoChildren;

@property (nonatomic, strong) SFCollectionViewManager *sfCollectionViewManager;
@property (nonatomic, strong) SFDefaultCollectionViewDelegate *sfDefaultCollectionViewDelegate;
@property (nonatomic, strong) SFTableViewManager *sfTableViewManager;


@property (nonatomic, strong) NSArray *pendingItems;
@property (nonatomic, strong) NSMutableArray *smartFeedItemsArray;
@property (nonatomic, strong) NSArray *feedContentArray;

@property (nonatomic, strong) NSMutableDictionary *customNibsForWidgetId;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifierWidgetId;
@property (nonatomic, strong) NSMutableDictionary *customNibsForItemType;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifierItemType;


@property (nonatomic, copy) NSString *smartFeedHeadercCustomUIReuseIdentifier;

@property (nonatomic, assign) BOOL isTransparentBackground;

@property (nonatomic, strong) NSDate *initializationTime;
@property (nonatomic, assign) BOOL isViewabilityPerListingEnabled;

@property (nonatomic, strong) SFDefaultDelegate *defaultDelegate;

@end

@implementation SmartFeedManager

NSString * const kCustomUINib = @"CustomUINib";
NSString * const kCustomUIIdentifier = @"CustomUIIdentifier";

#pragma mark - init methods
- (id)init
{
    return [self initWithUrl:@"NULL" widgetID:@"NULL" collectionView:[[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewLayout alloc] init]]];
}

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
             collectionView:(UICollectionView * _Nonnull)collectionView
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        [self commonInitWithUrl:url widgetID:widgetId];

        self.sfCollectionViewManager = [[SFCollectionViewManager alloc] initWitCollectionView:collectionView];
        self.sfCollectionViewManager.eventListenerTarget = self;
        self.sfCollectionViewManager.wkWebviewDelegate = self;
    }
    return self;
}

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
                  tableView:(UITableView * _Nonnull)tableView
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        
        [self commonInitWithUrl:url widgetID:widgetId];
       
        self.sfTableViewManager = [[SFTableViewManager alloc] initWithTableView:tableView];
        self.sfTableViewManager.eventListenerTarget = self;
        self.sfTableViewManager.wkWebviewDelegate = self;
    }
    return self;
}

- (void)commonInitWithUrl:(NSString *)url
                   widgetID:(NSString *)widgetId
{
    self.initializationTime = [NSDate date];
    self.widgetId = widgetId;
    self.url = url;
    self.outbrainSectionIndex = -1;
    self.smartFeedItemsArray = [[NSMutableArray alloc] init];
    self.customNibsForWidgetId = [[NSMutableDictionary alloc] init];
    self.reuseIdentifierWidgetId = [[NSMutableDictionary alloc] init];
    self.customNibsForItemType = [[NSMutableDictionary alloc] init];
    self.reuseIdentifierItemType = [[NSMutableDictionary alloc] init];
    self.horizontalContainerMargin = 0;
    self.isVideoEligible = YES; // default value
    
    self.defaultDelegate = [[SFDefaultDelegate alloc] init];
    self.delegate = self.defaultDelegate;
}

-(void) setOutbrainWidgetIndex:(NSInteger)widgetIndex {
    _outbrainWidgetIndex = widgetIndex;
    self.lastIdx = widgetIndex;
}

-(NSInteger) smartFeedItemsCount {
    if (self.smartFeedItemsArray.count > 0) {
        return self.smartFeedItemsArray.count + 1; // plus header cell
    }
    else {
        return 0;
    }
}

- (void)setDisplaySourceOnOrganicRec:(BOOL)displaySourceOnOrganicRec {
    _displaySourceOnOrganicRec = displaySourceOnOrganicRec;
    if (self.sfCollectionViewManager) {
        self.sfCollectionViewManager.displaySourceOnOrganicRec = displaySourceOnOrganicRec;
    }
    if (self.sfTableViewManager) {
        self.sfTableViewManager.displaySourceOnOrganicRec = displaySourceOnOrganicRec;
    }
}

-(void) setDisableCellShadows:(BOOL)disableCellShadows {
    _disableCellShadows = disableCellShadows;
    if (self.sfCollectionViewManager) {
        self.sfCollectionViewManager.disableCellShadows = disableCellShadows;
    }
    if (self.sfTableViewManager) {
        self.sfTableViewManager.disableCellShadows = disableCellShadows;
    }
}

-(void) setDarkMode:(BOOL)darkMode {
    _darkMode = darkMode;
    [[SFUtils sharedInstance] setDarkMode:darkMode];
}

#pragma mark - Fetch Recommendations
- (void) fetchMoreRecommendations {
    if (self.isLoading) {
        return;
    }
    
    if ([self finishedLoadingAllItemsInSmartfeed]) {
        return;
    }
    
    if (self.outbrainSectionIndex < 0) {
        NSLog(@"fetchMoreRecommendations ---> outbrainSectionIndex < 0");
        return;
    }
    
    self.isLoading = YES;
    if (self.smartFeedItemsArray.count == 0) {
        [self loadFirstTimeForFeed];
    }
    else {
        [self fetchMoreRecommendationsWithMultivac];
    }
}

- (void)setUseDefaultCollectionViewDelegate:(BOOL)useDefaultCollectionViewDelegate {
    _useDefaultCollectionViewDelegate = useDefaultCollectionViewDelegate;
    self.sfDefaultCollectionViewDelegate = [[SFDefaultCollectionViewDelegate alloc] initWithSmartfeedManager:self];
    if (useDefaultCollectionViewDelegate && self.sfCollectionViewManager) {
        self.sfCollectionViewManager.collectionView.delegate = self.sfDefaultCollectionViewDelegate;
        self.sfCollectionViewManager.collectionView.dataSource = self.sfDefaultCollectionViewDelegate;
    }
}

-(void) loadFirstTimeForFeed {
    OBRequest *request = [OBRequest requestWithURL:self.url widgetID:self.widgetId widgetIndex:self.outbrainWidgetIndex];
    if (self.externalID) {
        request.externalID = self.externalID;
    }
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        if (response.error) {
            NSLog(@"Error in fetchRecommendations - %@, for widget id: %@", response.error.localizedDescription, request.widgetId);
            return;
        }
        
        if (response.settings.isSmartFeed == YES) {
            self.feedContentArray = response.settings.feedContentArray;
            self.isRTL = response.settings.isRTL;
            [SFUtils setSkipRTL:!self.isRTL]; // Sky optimization
            if (self.feedContentArray == nil || self.feedContentArray.count == 0) {
                self.isSmartfeedWithNoChildren = YES;
            }
            self.isViewabilityPerListingEnabled = response.settings.isViewabilityPerListingEnabled;
            NSInteger viewabilityPerListingReportingIntervalMillis = response.settings.viewabilityPerListingReportingIntervalMillis;
            if (self.isViewabilityPerListingEnabled) {
                [[SFViewabilityService sharedInstance] startReportViewabilityWithTimeInterval:viewabilityPerListingReportingIntervalMillis];
            }
            self.fab = [response.responseRequest getStringValueForPayloadKey:@"abTestVal"];
            if ([self.fab isEqualToString:@"no_abtest"]) {
                self.fab = nil;
            }
        }
        
        if (response.recommendations.count == 0) {
            NSLog(@"Error in fetchRecommendations - 0 recs for widget id: %@", request.widgetId);
            return;
        }
        
        // NSLog(@"loadFirstTimeForFeed received - %d recs, for widget id: %@", response.recommendations.count, request.widgetId);
        
        NSArray *parentSmartfeedItems = [self createSmartfeedItemsArrayFromResponse:response];
        if ([self.delegate respondsToSelector:@selector(smartFeedResponseReceived:forWidgetId:)]) {
            [self.delegate smartFeedResponseReceived:response.recommendations forWidgetId:request.widgetId];
        }
        
        if (self.isSmartfeedWithNoChildren) {
            [self reloadUIData: parentSmartfeedItems];
        }
        else {
            self.pendingItems = parentSmartfeedItems;
            [self fetchMoreRecommendationsWithMultivac];
        }
    }];
}

-(void) fetchMoreRecommendationsWithMultivac {
    OBRequest *request = [OBRequest requestWithURL:self.url widgetID:self.widgetId widgetIndex:self.outbrainWidgetIndex];
    request.lastCardIdx = self.lastCardIdx;
    request.lastIdx = self.lastIdx;
    request.isMultivac = YES;
    request.fab = self.fab;
    
    if (self.externalID) {
        request.externalID = self.externalID;
    }
    
    [[OutbrainManager sharedInstance] fetchMultivacWithRequest:request andDelegate:self];
}

-(NSArray *) createSmartfeedItemsArrayFromResponse:(OBRecommendationResponse *)response {
    NSString *widgetTitle = response.settings.widgetHeaderText;
    NSMutableArray *newSmartfeedItems = [[NSMutableArray alloc] init];
    
    if (response.recommendations.count == 0) {
        NSLog(@"Error - ODB response with zero recs.. widget id: %@, req_id: %@",
              [response.responseRequest getStringValueForPayloadKey:@"widgetJsId"],
              [response.responseRequest getStringValueForPayloadKey:@"req_id"]);
        return @[];
    }
    
    for (OBRecommendation *rec in response.recommendations) {
        [[SFImageLoader sharedInstance] loadImageToCacheIfNeeded:rec.image.url];
    }
    
    if ([SFUtils isVideoIncludedInResponse:response] && response.recommendations.count == 1 && self.isVideoEligible) {
        NSString *videoParamsStr = [SFUtils videoParamsStringFromResponse:response];
        
        NSURL *videoURL = [SFUtils appendParamsToVideoUrl: response url:self.url];
        OBRecommendation *rec = response.recommendations[0];
        SFItemData *item = [[SFItemData alloc] initWithVideoUrl:videoURL
                                                    videoParamsStr:videoParamsStr
                                           singleRecommendation:rec
                                                    odbResponse:response];
        
        [newSmartfeedItems addObject:item];
        // New implementation for Video - if video available there can only be one item in the response (paid + video)
        return newSmartfeedItems;
    }
    
    SFItemType itemType = [self sfItemTypeFromResponse:response];
    
   // itemType = SFTypeCarouselWithTitle;
    
    switch (itemType) {
        case SFTypeCarouselWithTitle:
        case SFTypeCarouselNoTitle:
        case SFTypeBrandedCarouselWithTitle:
            [newSmartfeedItems addObjectsFromArray:[self createCarouselItemArrayFromResponse:response templateType:itemType widgetTitle:widgetTitle]];
            break;
        case SFTypeGridTwoInRowNoTitle:
        case SFTypeGridTwoInRowWithTitle:
        case SFTypeGridThreeInRowNoTitle:
        case SFTypeGridThreeInRowWithTitle:
            [newSmartfeedItems addObjectsFromArray:[self createGridItemsFromResponse:response templateType:itemType widgetTitle:widgetTitle]];
            break;
        case SFTypeStripNoTitle:
        case SFTypeStripWithTitle:
        case SFTypeStripWithThumbnailNoTitle:
        case SFTypeStripWithThumbnailWithTitle:
            [newSmartfeedItems addObjectsFromArray:[self createSingleItemArrayFromResponse:response templateType:itemType widgetTitle:widgetTitle]];
            break;
        default:
            NSLog(@"Error - createSmartfeedItemsArrayFromResponse - itemType (%@) not found", [SFItemData itemTypeString:itemType]);
            break;
    }
   
    return newSmartfeedItems;
}

-(SFItemType) sfItemTypeFromResponse:(OBRecommendationResponse *)response {
    NSString *recMode = response.settings.recMode;
    NSString *widgetHeader = response.settings.widgetHeaderText;
    BOOL isParentResponse = response.settings.isSmartFeed;
    
    if (isParentResponse) {
        // for the first widget in the feed, the widgetHeader text goes into the header
        // see configureSmartFeedHeaderTableViewCell:
        widgetHeader = nil;
    }
    
    if ([recMode isEqualToString:@"sdk_sfd_swipe"]) {
        return SFTypeBrandedCarouselWithTitle; //TODO remove this line
//        return widgetHeader ? SFTypeCarouselWithTitle : SFTypeCarouselNoTitle;
    }
    else if ([recMode isEqualToString:@"sdk_sfd_1_column"]) {
        return widgetHeader ? SFTypeStripWithTitle : SFTypeStripNoTitle;
    }
    else if ([recMode isEqualToString:@"sdk_sfd_2_columns"]) {
        return widgetHeader ? SFTypeGridTwoInRowWithTitle : SFTypeGridTwoInRowNoTitle;
    }
    else if ([recMode isEqualToString:@"sdk_sfd_3_columns"]) {
        return widgetHeader ? SFTypeGridThreeInRowWithTitle : SFTypeGridThreeInRowNoTitle;
    }
    else if ([recMode isEqualToString:@"sdk_sfd_thumbnails"]) {
        return widgetHeader ? SFTypeStripWithThumbnailWithTitle : SFTypeStripWithThumbnailNoTitle;        
    }
    else if ([recMode isEqualToString:@"odb_dynamic_ad-carousel"]) {
        return SFTypeBrandedCarouselWithTitle;
    }
    
    NSLog(@"recMode value is not currently covered in the SDK - (%@)", recMode);
    return SFTypeStripWithTitle;
}

-(NSArray *) createSingleItemArrayFromResponse:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;
    NSMutableArray *newSmartfeedItems = [[NSMutableArray alloc] init];
    for (OBRecommendation *rec in recommendations) {
        SFItemData *item = [[SFItemData alloc] initWithSingleRecommendation:rec
                                                                 odbResponse:response
                                                                        type:templateType];
        
        [newSmartfeedItems addObject:item];
        
    }
    return newSmartfeedItems;
}

-(NSArray *) createCarouselItemArrayFromResponse:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;

    if (response.settings.isTrendingInCategoryCard && recommendations.count > 0) {
        OBRecommendation *rec = recommendations[0];
        response.settings.widgetHeaderText = [NSString stringWithFormat:@"%@ %@", response.settings.widgetHeaderText, rec.categoryName];
    }
    SFItemData *item = [[SFItemData alloc] initWithList:recommendations
                                            odbResponse:response
                                                   type:templateType];
    
    return @[item];
}

-(NSArray *) createGridItemsFromResponse:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;
    
    BOOL shouldIncludeVideo =
        [SFUtils isVideoIncludedInResponse:response] &&
        (templateType == SFTypeGridTwoInRowNoTitle ||
         templateType == SFTypeGridTwoInRowWithTitle) &&
        self.isVideoEligible;
    
    NSMutableArray *newSmartfeedItems = [[NSMutableArray alloc] init];
    
    if (shouldIncludeVideo) {
        BOOL videoItemIndex = recommendations.count == 6 ? 1 : 0;
        [self addTwoItemsInLineWithVideoToNewItemsList:newSmartfeedItems response:response videoItemIndex:videoItemIndex templateType:templateType widgetTitle:widgetTitle];
    } else {
        [self addItemsInLineToNewItemsList:newSmartfeedItems response:response templateType:templateType];
    }

    return newSmartfeedItems;
}

-(void) addTwoItemsInLineWithVideoToNewItemsList:(NSMutableArray *) newSmartfeedItems response:(OBRecommendationResponse *)response videoItemIndex:(int)videoItemIndex templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;
    BOOL isParentResponse = response.settings.isSmartFeed;
    
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    while (recommendationsMutableArray.count >= 2) {
        NSRange subRange = NSMakeRange(0, 2);
        NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
        [recommendationsMutableArray removeObjectsInRange:subRange];
        
        if (newSmartfeedItems.count == videoItemIndex) {
            NSString *videoParamsStr = [SFUtils videoParamsStringFromResponse:response];
            NSURL *videoURL = [SFUtils appendParamsToVideoUrl: response url:self.url];
            SFItemType newTemplateType = !isParentResponse && widgetTitle ?
                SFTypeGridTwoInRowWithTitleWithVideo :
                SFTypeGridTwoInRowWithVideo;
            SFItemData *videoItem = [[SFItemData alloc] initWithVideoUrl:videoURL
                                                          videoParamsStr:videoParamsStr
                                                                 reclist:singleLineRecs
                                                             odbResponse:response
                                                                    type: newTemplateType];
            
            [newSmartfeedItems addObject:videoItem];
            continue;
        }
        
        SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs
                                                odbResponse:response
                                                       type:templateType];
        
        [newSmartfeedItems addObject:item];
    }
}

-(void) addItemsInLineToNewItemsList:(NSMutableArray *) newSmartfeedItems response:(OBRecommendationResponse *)response templateType:(SFItemType)templateType {
    NSArray *recommendations = response.recommendations;
    
    NSUInteger itemsPerRow = 0;
    if (templateType == SFTypeGridTwoInRowNoTitle || templateType == SFTypeGridTwoInRowWithTitle) {
        itemsPerRow = 2;
    }
    else if (templateType == SFTypeGridThreeInRowNoTitle || templateType == SFTypeGridThreeInRowWithTitle) {
        itemsPerRow = 3;
    }
    else {
        NSAssert(NO, @"templateType has illegal value");
    }
    
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    while (recommendationsMutableArray.count >= itemsPerRow) {
        NSRange subRange = NSMakeRange(0, itemsPerRow);
        NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
        [recommendationsMutableArray removeObjectsInRange:subRange];
        
        SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs
                                                odbResponse:response
                                                       type:templateType];
        
        [newSmartfeedItems addObject:item];
    }
}


-(void) reloadUIData:(NSArray *) newSmartfeedItems {
    
    self.isLoading = NO;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    
    if (self.smartFeedItemsArray.count == 0) {
        // add Header first
        [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:self.outbrainSectionIndex]];
    }
    
    // build the index paths for insertion
    // since you're adding to the end of datasource, the new rows will start at count + 1 (header)
    NSInteger baseIndex = self.smartFeedItemsArray.count+1;
    for (int i = 0; i < newSmartfeedItems.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:baseIndex+i inSection:self.outbrainSectionIndex]];
    }
    NSIndexPath *firstIdx = indexPaths[0];
    
    if (self.isInMiddleOfScreen && self.smartFeedItemsArray.count == 0) {
        [self.smartFeedItemsArray addObjectsFromArray:newSmartfeedItems];
        
        if ([self.delegate respondsToSelector:@selector(smartfeedIsReadyWithRecs)]) {
            [self.delegate smartfeedIsReadyWithRecs];
        }
    }
    else if (self.sfCollectionViewManager) {
        if (self.sfCollectionViewManager.collectionView != nil) {
            [self.sfCollectionViewManager.collectionView performBatchUpdates:^{
                [self.smartFeedItemsArray addObjectsFromArray:newSmartfeedItems];
                
                if (firstIdx.row == 0) {
                    [self.sfCollectionViewManager.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.outbrainSectionIndex]];
                }
                [self.sfCollectionViewManager.collectionView insertItemsAtIndexPaths:indexPaths];
                
            } completion:^(BOOL finished) {
                if (self.isInMiddleOfScreen && [self.delegate respondsToSelector:@selector(smartfeedIsReadyWithRecs)]) {
                    [self.delegate smartfeedIsReadyWithRecs];
                }
            }];
        }
    }
    else if (self.sfTableViewManager) {
        if (self.sfTableViewManager.tableView != nil) {
            // tell the table view to update (at all of the inserted index paths)
            UITableView *tableView = self.sfTableViewManager.tableView;
            
            // Check if Sky solution is needed
            if (self.isSkySolutionActive) {
                [self skySolutionForTableViewReload:tableView newSmartfeedItems:newSmartfeedItems indexPaths:indexPaths];
                return;
            }

            [tableView beginUpdates];
            [self.smartFeedItemsArray addObjectsFromArray:newSmartfeedItems];
            [tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            [tableView endUpdates];
        }
    }
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return nil;
    }
    
    if (indexPath.row >= [self smartFeedItemsCount]) {
        return [[UITableViewCell alloc] init];
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header cell
        if (self.smartFeedHeadercCustomUIReuseIdentifier) {
            return [self.sfTableViewManager.tableView dequeueReusableCellWithIdentifier:self.smartFeedHeadercCustomUIReuseIdentifier forIndexPath:indexPath];
        }
        return [self.sfTableViewManager tableView:tableView headerCellForRowAtIndexPath:indexPath isRTL:self.isRTL];
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    UINib *singleItemCellNib = nil;
    NSString *singleCellIdentifier = nil;
    NSMutableDictionary *customNibAndIdentifierDictionary = [self getCustomNibAndIdentifierForSFItem:sfItem];
    if (customNibAndIdentifierDictionary) {
        singleItemCellNib = customNibAndIdentifierDictionary[kCustomUINib];
        singleCellIdentifier = customNibAndIdentifierDictionary[kCustomUIIdentifier];
    }
    
    if (singleItemCellNib && sfItem.singleRec) {
        UIView *rootView = [[singleItemCellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        if (![rootView isKindOfClass:[UITableViewCell class]]) {
            NSLog(@"%@", [NSString stringWithFormat:@"Nib for reuseIdentifier (%@) is not type of UITableViewCell. --> reverting back to default", singleCellIdentifier]);
            singleItemCellNib = nil; // reverting back to default
        }
    }

    if (singleItemCellNib && singleCellIdentifier && sfItem.singleRec) { // custom UI
        [self.sfTableViewManager.tableView registerNib:singleItemCellNib forCellReuseIdentifier:singleCellIdentifier];
        sfItem.isCustomUI = YES;
        return [self.sfTableViewManager.tableView dequeueReusableCellWithIdentifier:singleCellIdentifier forIndexPath:indexPath];
    }
    return [self.sfTableViewManager tableView:tableView cellForRowAtIndexPath:indexPath sfItemType:sfItem.itemType];
}

- (NSInteger)numberOfSectionsInTableView {
    return self.outbrainSectionIndex + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.smartFeedItemsArray.count == 0) {
        [self fetchMoreRecommendations];
        return;
    }
    
    if (indexPath.section != self.outbrainSectionIndex) {
        return;
    }
    
    if (indexPath.row >= [self smartFeedItemsCount]) {
        return;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header
        [self configureSmartFeedHeaderTableViewCell:cell atIndexPath:indexPath];
        return;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    // Report Viewability
    if (!self.isViewabilityPerListingEnabled) {
        NSString *reqId = [sfItem.responseRequest getStringValueForPayloadKey:@"req_id"];
        [[OBViewabilityService sharedInstance] reportRecsShownForRequestId:reqId];
    }
    // else.. will be reported in SFViewabilityService (per listing)
    
    if (self.isViewabilityPerListingEnabled) {
        [[SFViewabilityService sharedInstance] configureViewabilityPerListingForCell:cell withSFItem:sfItem initializationTime:self.initializationTime];
    }
    
    if ([cell isKindOfClass:[SFHorizontalWithVideoTableViewCell class]]) {
        [self configureHorizontalVideoTableViewCell:cell atIndexPath:indexPath];
    }
    else if ([cell isKindOfClass:[SFHorizontalTableViewCell class]]) {
        [self configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)cell atIndexPath:indexPath];
        if (!self.disableCellShadows && (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle)) {
            [SFUtils addDropShadowToView: cell];
        }
    }
    else if ([cell isKindOfClass:[SFVideoTableViewCell class]] ||
             sfItem.itemType == SFTypeStripVideoWithPaidRecAndTitle ||
             sfItem.itemType == SFTypeStripVideoWithPaidRecNoTitle)
    {
        [self.sfTableViewManager configureVideoCell:cell atIndexPath:indexPath withSFItem:sfItem];
    }
    else { // SFSingleCell
        [self.sfTableViewManager configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:indexPath withSFItem:sfItem];
    }
    
    BOOL smartfeedScrollNearBottom = indexPath.row >= (self.smartFeedItemsArray.count - 4);
    BOOL smartfeedCountVerySmall = self.smartFeedItemsArray.count < 6;
    if (!self.isInMiddleOfScreen && (smartfeedScrollNearBottom || smartfeedCountVerySmall)) {
        [self fetchMoreRecommendations];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // Smartfeed header
        return UITableViewAutomaticDimension;
    }
    if (indexPath.row >= [self smartFeedItemsCount]) {
        return 0.1;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return [self.sfTableViewManager heightForRowAtIndexPath:indexPath withSFItem:sfItem];
}

- (void) configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)horizontalCell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalCell withCellTitleLabel:horizontalCell.titleLabel sfItem:sfItem];
    
    if (!sfItem.isCustomUI) {
        horizontalCell.backgroundColor = [[SFUtils sharedInstance] primaryBackgroundColor];
    }
}

- (void) configureHorizontalVideoTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalWithVideoTableViewCell *horizontalVideoCell = (SFHorizontalWithVideoTableViewCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalVideoCell withCellTitleLabel:horizontalVideoCell.titleLabel sfItem:sfItem];
    
    if ([self.delegate respondsToSelector:@selector(isVideoCurrentlyPlaying)] &&
        self.delegate.isVideoCurrentlyPlaying) {
        return;
    }
    
    BOOL shouldReturn = [SFUtils configureGenericVideoCell:horizontalVideoCell sfItem:sfItem];
    if (shouldReturn) {
        return;
    }
    
    horizontalVideoCell.webview = [SFUtils createVideoWebViewInsideView:horizontalVideoCell.horizontalView withSFItem:sfItem scriptMessageHandler:horizontalVideoCell.wkScriptMessageHandler uiDelegate:self withHorizontalMargin:YES];
    
    [SFUtils loadVideoURLIn:horizontalVideoCell sfItem:sfItem];
    
    if (!sfItem.isCustomUI) {
        horizontalVideoCell.backgroundColor = [[SFUtils sharedInstance] primaryBackgroundColor];
    }
}

-(void) commonConfigureHorizontalCell:(id<SFHorizontalCellCommonProps>)horizontalCell withCellTitleLabel:(UILabel *)cellTitleLabel sfItem:(SFItemData *)sfItem {
    SFHorizontalView *horizontalView = horizontalCell.horizontalView;
    
    if (self.horizontalContainerMargin != 0) {
        horizontalCell.horizontalViewLeadingConstraint.constant = self.horizontalContainerMargin;
        horizontalCell.horizontalViewTrailingConstraint.constant = self.horizontalContainerMargin;
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *horizontalItemCellNib = nil;
    NSString *horizontalCellIdentifier = nil;
    NSMutableDictionary *customNibAndIdentifierDictionary = [self getCustomNibAndIdentifierForSFItem:sfItem];
    if (customNibAndIdentifierDictionary) {
        horizontalItemCellNib = customNibAndIdentifierDictionary[kCustomUINib];
        horizontalCellIdentifier = customNibAndIdentifierDictionary[kCustomUIIdentifier];
    }
    
    if (horizontalItemCellNib) {
        UIView *rootView = [[horizontalItemCellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        if (![rootView isKindOfClass:[UICollectionViewCell class]]) {
            NSLog(@"%@", [NSString stringWithFormat:@"Nib for reuseIdentifier (%@) is not type of UICollectionViewCell. --> reverting back to default", horizontalCellIdentifier]);
            horizontalItemCellNib = nil; // reverting back to default
        }
    }
    
    if (cellTitleLabel) {
        if (sfItem.widgetTitle) {
            cellTitleLabel.text = sfItem.widgetTitle;
        }
        else {
            // fallback
            cellTitleLabel.text = @"Around the web";
        }
    }
    
    if (horizontalItemCellNib && horizontalCellIdentifier) { // custom UI
        sfItem.isCustomUI = YES;
        [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: horizontalCellIdentifier];
    }
    else { // default UI
        if (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle) { // carousel
            horizontalItemCellNib = [UINib nibWithNibName:@"SFHorizontalItemCell" bundle:bundle];
            [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFHorizontalItemCell"];
        }
        if (sfItem.itemType == SFTypeBrandedCarouselWithTitle) { // branded carousel
            horizontalItemCellNib = [UINib nibWithNibName:@"SFBrandedCardItemCell" bundle:bundle];
            [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFBrandedCardItemCell"];
        }
        else { // SFHorizontalFixed
            horizontalItemCellNib = [UINib nibWithNibName:@"SFHorizontalFixedItemCell" bundle:bundle];
            [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFHorizontalFixedItemCell"];
        }
    }
    
    horizontalView.sfItem = sfItem;
    horizontalView.shadowColor = sfItem.shadowColor;
    horizontalView.displaySourceOnOrganicRec = self.displaySourceOnOrganicRec;
    horizontalView.disableCellShadows = self.disableCellShadows;
    
    [horizontalView setupView];
    [horizontalView setOnRecommendationClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
    [horizontalView setOnAdChoicesIconClick:^(NSURL *url) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnAdChoicesIcon:url];
        }
    }];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(carouselItemSize)]) {
        [horizontalView setCarouselItemSizeCallback:^CGSize{
            return [self.delegate carouselItemSize];
        }];
    }
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(configureHorizontalItem:withRec:)]) {
        [horizontalView setConfigureHorizontalItem:^(SFCollectionViewCell *cell, OBRecommendation *rec) {
            [self.delegate configureHorizontalItem:cell withRec:rec];
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // reload cells again because the first render always displays the wrong size.
        [horizontalView setupView];
        [horizontalView.collectionView reloadData];
        
        if (!sfItem.isCustomUI && cellTitleLabel) {
            cellTitleLabel.textColor = [[SFUtils sharedInstance] subtitleColor:nil];
        }
        
        UIColor *defaultBGColor = !sfItem.isCustomUI ? [[SFUtils sharedInstance] primaryBackgroundColor] : UIColor.whiteColor;
        
        if (self.isTransparentBackground) {
            defaultBGColor = UIColor.clearColor;
        }
        horizontalView.backgroundColor = defaultBGColor;
        horizontalView.collectionView.backgroundColor = defaultBGColor;
        if ([horizontalCell respondsToSelector:@selector(cellView)]) {
            horizontalCell.cellView.backgroundColor = defaultBGColor;
        }
    });
}

- (void) configureSmartFeedHeaderTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:1 inSection:self.outbrainSectionIndex]];
    SFTableViewHeaderCell *sfHeaderCell = (SFTableViewHeaderCell *)cell;
    if (sfItem.widgetTitle) {
        sfHeaderCell.headerLabel.text = sfItem.widgetTitle;
    }
    
    if (!sfItem.isCustomUI) {
        sfHeaderCell.backgroundColor = [[SFUtils sharedInstance] primaryBackgroundColor];
        sfHeaderCell.headerLabel.textColor = [[SFUtils sharedInstance] titleColor:YES];
    }
    
    if (self.isSmartfeedWithNoChildren) {
        // Remove Smartfeed logo and place Outbrain regular logo instead
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        sfHeaderCell.headerImageView.image = [UIImage imageNamed:@"outbrain-logo" inBundle:bundle compatibleWithTraitCollection:nil];
        [sfHeaderCell.adChoicesImageView removeFromSuperview];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(outbrainLabelClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [sfHeaderCell.contentView addGestureRecognizer:tapGesture];
}

- (void) skySolutionForTableViewReload:(UITableView *)tableView newSmartfeedItems:(NSArray *)newSmartfeedItems indexPaths:(NSArray *)indexPaths {
    [self.smartFeedItemsArray addObjectsFromArray:newSmartfeedItems];
    
    // Check if there is an overlap between visibleIndexPathArray and the new IndexPaths we are about to add.
    NSArray *visibleIndexPathArray = [tableView indexPathsForVisibleRows];
    NSMutableSet *set1 = [NSMutableSet setWithArray: visibleIndexPathArray];
    NSSet *set2 = [NSSet setWithArray: indexPaths];
    [set1 intersectSet: set2];
    NSArray *resultArray = [set1 allObjects];
    
    if ([resultArray count] > 1) {
        // Detected overlap - calling reloadRowsAtIndexPaths (this will initiate a call to heightForRowAt:
        [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // Smartfeed header cell
        if (self.smartFeedHeadercCustomUIReuseIdentifier) {
            return [self.sfCollectionViewManager.collectionView dequeueReusableCellWithReuseIdentifier: self.smartFeedHeadercCustomUIReuseIdentifier forIndexPath:indexPath];
        }
        return [self.sfCollectionViewManager collectionView:collectionView headerCellForItemAtIndexPath:indexPath isRTL:self.isRTL];
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    UINib *singleItemCellNib = nil;
    NSString *singleCellIdentifier = nil;
    NSMutableDictionary *customNibAndIdentifierDictionary = [self getCustomNibAndIdentifierForSFItem:sfItem];
    if (customNibAndIdentifierDictionary) {
        singleItemCellNib = customNibAndIdentifierDictionary[kCustomUINib];
        singleCellIdentifier = customNibAndIdentifierDictionary[kCustomUIIdentifier];
    }
    
    if (singleItemCellNib && singleCellIdentifier && sfItem.singleRec) { // custom UI
        [self.sfCollectionViewManager.collectionView registerNib:singleItemCellNib forCellWithReuseIdentifier:singleCellIdentifier];
        sfItem.isCustomUI = YES;
        return [self.sfCollectionViewManager.collectionView dequeueReusableCellWithReuseIdentifier: singleCellIdentifier forIndexPath:indexPath];
    }
    return [self.sfCollectionViewManager collectionView:collectionView cellForItemAtIndexPath:indexPath sfItem:sfItem];
}

- (NSInteger)numberOfSectionsInCollectionView {
    return self.smartFeedItemsArray.count > 0 ? self.outbrainSectionIndex + 1 : self.outbrainSectionIndex;
}

- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView
                  layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    
    if (indexPath.section == self.outbrainSectionIndex) {
        if (indexPath.row == 0) {
            // Smartfeed header
            return CGSizeMake(collectionView.frame.size.width, 35);
        }
        SFItemData *sfItem = [self itemForIndexPath:indexPath];
        return [self.sfCollectionViewManager collectionView:collectionView sizeForItemAtIndexPath:indexPath sfItem:sfItem];
    }
    
    return CGSizeMake(0, 0);
}

- (void) collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.smartFeedItemsArray.count == 0) {
        [self fetchMoreRecommendations];
        return;
    }
    
    if (indexPath.section != self.outbrainSectionIndex) {
        return;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header
        SFItemData *sfItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:1 inSection:self.outbrainSectionIndex]];
        
        [self.sfCollectionViewManager configureSmartfeedHeaderCell:cell atIndexPath:indexPath withSFItem:sfItem isSmartfeedWithNoChildren:self.isSmartfeedWithNoChildren];
        return;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    // Report Viewability
    if (!self.isViewabilityPerListingEnabled) {
        NSString *reqId = [sfItem.responseRequest getStringValueForPayloadKey:@"req_id"];
        [[OBViewabilityService sharedInstance] reportRecsShownForRequestId:reqId];
    }
    // else.. will be reported in SFViewabilityService (per listing)
    
    if (self.isViewabilityPerListingEnabled) {
        [[SFViewabilityService sharedInstance] configureViewabilityPerListingForCell:cell withSFItem:sfItem initializationTime:self.initializationTime];
    }
    
    if ([cell isKindOfClass:[SFHorizontalWithVideoCollectionViewCell class]]) {
        [self configureHorizontalVideoCollectionCell:cell atIndexPath:indexPath];
    }
    else if ([cell isKindOfClass:[SFHorizontalCollectionViewCell class]]) {
        [self configureHorizontalCell:cell atIndexPath:indexPath];
        if (sfItem.itemType == SFTypeBrandedCarouselWithTitle) {
            [self configureBrandedCarouselCell:cell atIndexPath:indexPath];
        }
        if (!self.disableCellShadows && (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle || sfItem.itemType == SFTypeBrandedCarouselWithTitle)) {
            [SFUtils addDropShadowToView: cell]; // add shadow
        }
    }
    else if ([cell isKindOfClass:[SFVideoCollectionViewCell class]] ||
             sfItem.itemType == SFTypeStripVideoWithPaidRecAndTitle ||
             sfItem.itemType == SFTypeStripVideoWithPaidRecNoTitle)
    {
        [self.sfCollectionViewManager configureVideoCell:cell atIndexPath:indexPath withSFItem:sfItem];
    }
    else { // SFSingleCell
        [self.sfCollectionViewManager configureSingleCell:cell atIndexPath:indexPath withSFItem:sfItem];
    }
    
    if (!self.isInMiddleOfScreen && indexPath.row >= self.smartFeedItemsArray.count - 2) {
        [self fetchMoreRecommendations];
    }
}

- (SFItemData *) itemForIndexPath:(NSIndexPath *)indexPath {
    return self.smartFeedItemsArray[indexPath.row-1];
}
    
- (void) configureHorizontalCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalCollectionViewCell *horizontalCell = (SFHorizontalCollectionViewCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalCell withCellTitleLabel:horizontalCell.titleLabel sfItem:sfItem];
}

- (void) configureBrandedCarouselCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFBrandedCarouselCollectionCell *brandedCarouselCell = (SFBrandedCarouselCollectionCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    brandedCarouselCell.cellBrandLogoImageView.image = [UIImage imageNamed:@"cnn-logo"];
    for (UIView *v in brandedCarouselCell.horizontalPagerIndicatorStackView.arrangedSubviews) {
        [v removeFromSuperview];
    }
    for (int i=0; i <= 5; i++) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = (i == 0) ? UIColor.blackColor : UIColor.whiteColor;
        v.layer.borderWidth = 2.0;
        v.layer.borderColor = (i == 0) ? UIColor.blackColor.CGColor : UIColorFromRGB(0x9b9b9b).CGColor;
        v.layer.cornerRadius = 5.0;
        
        v.tag = i;
        [v.heightAnchor constraintEqualToConstant:10].active = true;
        [v.widthAnchor constraintEqualToConstant:10].active = true;
        [brandedCarouselCell.horizontalPagerIndicatorStackView addArrangedSubview:v];
    }
    
    NSLog(@"total recs in branded carousel: %d", sfItem.outbrainRecs.count);
}


- (void) configureHorizontalVideoCollectionCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalWithVideoCollectionViewCell *horizontalVideoCell = (SFHorizontalWithVideoCollectionViewCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalVideoCell withCellTitleLabel:horizontalVideoCell.titleLabel sfItem:sfItem];
    
    if ([self.delegate respondsToSelector:@selector(isVideoCurrentlyPlaying)] &&
        self.delegate.isVideoCurrentlyPlaying) {
        return;
    }
    
    BOOL shouldReturn = [SFUtils configureGenericVideoCell:horizontalVideoCell sfItem:sfItem];
    if (shouldReturn) {
        return;
    }
    
    horizontalVideoCell.webview = [SFUtils createVideoWebViewInsideView:horizontalVideoCell.horizontalView withSFItem:sfItem scriptMessageHandler:horizontalVideoCell.wkScriptMessageHandler uiDelegate:self withHorizontalMargin:YES];
    
    [SFUtils loadVideoURLIn:horizontalVideoCell sfItem:sfItem];
}

- (NSMutableDictionary *) getCustomNibAndIdentifierForSFItem: (SFItemData *)sfItem {
    // App developer can set Custom UI for widgetID or item type.
    // In case both are present, widgetID will precedence.
    NSMutableDictionary *customNibAndIdentifierDictionary = [[NSMutableDictionary alloc] init];
    NSNumber *itemType = [NSNumber numberWithInteger:sfItem.itemType];
    UINib *itemCellNibForWidgetId = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *itemCellIdentifierForWidgetId = self.reuseIdentifierWidgetId[sfItem.widgetId];
    UINib *itemCellNibForItemType = self.customNibsForItemType[itemType];
    NSString *itemCellIdentifierForItemType = self.reuseIdentifierItemType[itemType];
    if (itemCellNibForWidgetId && itemCellIdentifierForWidgetId) { // widgetID
        customNibAndIdentifierDictionary[kCustomUINib] = itemCellNibForWidgetId;
        customNibAndIdentifierDictionary[kCustomUIIdentifier] = itemCellIdentifierForWidgetId;
        return customNibAndIdentifierDictionary;
    } else if (itemCellNibForItemType && itemCellIdentifierForItemType){ // itemType
        customNibAndIdentifierDictionary[kCustomUINib] = itemCellNibForItemType;
        customNibAndIdentifierDictionary[kCustomUIIdentifier] = itemCellIdentifierForItemType;
        return customNibAndIdentifierDictionary;
    } else {
        return nil;
    }
}

#pragma mark - SFEventListener methods

- (void) recommendationClicked: (id)sender
{
    UITapGestureRecognizer *gestureRec = sender;
    SFItemData *sfItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:gestureRec.view.tag inSection:self.outbrainSectionIndex]];
    OBRecommendation *rec = sfItem.singleRec;
    
    if (self.delegate != nil && rec != nil) {
        [self.delegate userTappedOnRecommendation:rec];
    }
}

- (void) adChoicesClicked:(id)sender {
    UIButton *adChoicesButton = sender;
    SFItemData *sfItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:adChoicesButton.tag inSection:self.outbrainSectionIndex]];
    OBRecommendation *rec = sfItem.singleRec;
    if (self.delegate != nil && rec != nil) {
        [self.delegate userTappedOnAdChoicesIcon:rec.disclosure.clickUrl];
    }
}

- (void) outbrainLabelClicked:(id)sender {
    NSLog(@"outbrainLabelClicked");
    if (self.delegate != nil) {
        [self.delegate userTappedOnOutbrainLabeling];
    }
}

- (BOOL) isVideoCurrentlyPlaying {
    if ([self.delegate respondsToSelector:@selector(isVideoCurrentlyPlaying)]) {
        return self.delegate.isVideoCurrentlyPlaying;
    }
        
    return NO;
}

#pragma mark - Common methods
-(BOOL) finishedLoadingAllItemsInSmartfeed {
    return [self.smartFeedItemsArray count] > 0 && !self.hasMore;
}

-(NSString *) keyForCellType:(SFItemType) type {
    NSString *itemTypeStr = [SFItemData itemTypeString:type];
    NSString *key = [NSString stringWithFormat:@"type_%@", itemTypeStr];
    return key;
}

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    if (self.sfCollectionViewManager != nil) {
        [self.sfCollectionViewManager registerSingleItemNib:nib forCellWithReuseIdentifier:identifier];
    }
    else {
        [self.sfTableViewManager registerSingleItemNib:nib forCellWithReuseIdentifier:identifier];
    }
}

- (void) registerNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier forWidgetId:(NSString *)widgetId {
    self.customNibsForWidgetId[widgetId] = nib;
    self.reuseIdentifierWidgetId[widgetId] = identifier;
}

-(NSString *) sfItemTypeStringFor:(NSIndexPath *)indexPath {
    SFItemType itemType = [self sfItemTypeFor:indexPath];
    return [SFItemData itemTypeString:itemType];
}

-(SFItemType) sfItemTypeFor:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return SFTypeBadType;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header cell
        return SFTypeSmartfeedHeader;
    }
    
    if (indexPath.row >= [self smartFeedItemsCount]) {
        return SFTypeBadType;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return sfItem.itemType;
}

- (void) registerNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier forSFItemType:(SFItemType)itemType {
    // We handle Header cell override differently
    if (itemType == SFTypeSmartfeedHeader) {
        [self registerHeaderNib:nib withReuseIdentifier:identifier];
        return;
    }
    
    NSNumber *convertedItemType = [NSNumber numberWithInteger: itemType];
    self.customNibsForItemType[convertedItemType] = nib;
    self.reuseIdentifierItemType[convertedItemType] = identifier;
}

- (void) registerHeaderNib:(UINib * _Nonnull )nib withReuseIdentifier:( NSString * _Nonnull )identifier {
    UIView *rootView = [[nib instantiateWithOwner:self options:nil] objectAtIndex:0];
    
    if (self.sfCollectionViewManager != nil) {
        if (![rootView isKindOfClass:[UICollectionViewCell class]]) {
            NSLog(@"%@", [NSString stringWithFormat:@"Nib for reuseIdentifier (%@) is not type of UICollectionViewCell. --> reverting back to default", identifier]);
            return; // reverting back to default
        }
        [self.sfCollectionViewManager registerSingleItemNib:nib forCellWithReuseIdentifier:identifier];
    }
    else {
        if (![rootView isKindOfClass:[UITableViewCell class]]) {
            NSLog(@"%@", [NSString stringWithFormat:@"Nib for reuseIdentifier (%@) is not type of UITableViewCell. --> reverting back to default", identifier]);
            return; // reverting back to default
        }
        [self.sfTableViewManager registerSingleItemNib:nib forCellWithReuseIdentifier:identifier];
    }
    
    self.smartFeedHeadercCustomUIReuseIdentifier = identifier;
}

- (void) setTransparentBackground:(BOOL)isTransparentBackground {
    self.isTransparentBackground = isTransparentBackground;
}

-(NSArray * _Nullable) recommendationsForIndexPath:(NSIndexPath * _Nonnull)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return nil;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header        
        return nil;
    }
    
    if (indexPath.row >= [self smartFeedItemsCount]) {
        return nil;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    if (sfItem.singleRec) {
        return @[sfItem.singleRec];
    }
    else if (sfItem.outbrainRecs) {
        return sfItem.outbrainRecs;
    }
    
    return nil;
}

-(void) pauseVideo {
    [[NSNotificationCenter defaultCenter]
        postNotificationName: OB_VIDEO_PAUSE_NOTIFICATION
        object:self];
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil) {
        // NSLog(@"SmartFeedManager createWebViewWith URL: %@", navigationAction.request.URL);
        if (self.delegate != nil && navigationAction.request.URL != nil) {
            [self.delegate userTappedOnVideoRec:navigationAction.request.URL];
        }
    }
    return nil;
}

#pragma mark - MultivacResponseDelegate

- (void)onMultivacSuccess:(NSArray<OBRecommendationResponse *> *)cardsResponseArray feedIdx:(NSInteger)feedIdx hasMore:(BOOL)hasMore {
    NSMutableArray *newSmartfeedItems = self.pendingItems ? [self.pendingItems mutableCopy] : [[NSMutableArray alloc] init];
    self.pendingItems = nil;
    
    self.hasMore = hasMore;
    NSInteger cardsCount = [cardsResponseArray count];
    self.lastCardIdx += cardsCount;
    self.lastIdx += cardsCount;
    
    for (NSInteger i=0; i < cardsResponseArray.count; i++) {
        OBRecommendationResponse *recResponse = cardsResponseArray[i];
        [newSmartfeedItems addObjectsFromArray:[self createSmartfeedItemsArrayFromResponse:recResponse]];
        NSString *widgetId = [recResponse.responseRequest getStringValueForPayloadKey:@"widgetJsId"];
        if ([self.delegate respondsToSelector:@selector(smartFeedResponseReceived:forWidgetId:)]) {
            [self.delegate smartFeedResponseReceived:recResponse.recommendations forWidgetId:widgetId];
        }
    }
    
    if (newSmartfeedItems.count == 0) {
        NSLog(@"Error in onMultivacSuccess - newSmartfeedItems.count == 0");
        self.isLoading = NO;
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadUIData: newSmartfeedItems];
    });
}

- (void)onMultivacFailure:(NSError *)error {
    self.isLoading = NO;
    NSLog(@"Error in fetchRecommendations - %@", error.localizedDescription);
}


@end
