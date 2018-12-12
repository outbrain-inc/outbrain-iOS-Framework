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
#import "SFHorizontalWithVideoCollectionViewCell.h"
#import "SFHorizontalWithVideoTableViewCell.h"
#import "SFCollectionViewCell.h"
#import "SFTableViewCell.h"
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
#import <OutbrainSDK/OutbrainSDK.h>


@interface SmartFeedManager() <SFClickListener, WKUIDelegate>

@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) NSString * _Nullable widgetId;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, strong) NSString *fid;
@property (nonatomic, assign) NSInteger feedCycleCounter;
@property (nonatomic, assign) NSInteger feedCycleLimit;
@property (nonatomic, assign) BOOL isRTL;

@property (nonatomic, assign) NSInteger outbrainIndex;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL isSmartfeedWithNoChildren;

@property (nonatomic, strong) SFCollectionViewManager *sfCollectionViewManager;
@property (nonatomic, strong) SFTableViewManager *sfTableViewManager;

@property (nonatomic, strong) NSMutableArray *smartFeedItemsArray;
@property (nonatomic, strong) NSMutableDictionary *customNibsForWidgetId;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifierWidgetId;

@property (nonatomic, copy) NSString *smartFeedHeadercCustomUIReuseIdentifier;

@property (nonatomic, assign) BOOL isTransparentBackground;

@end

@implementation SmartFeedManager


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
        self.sfCollectionViewManager.clickListenerTarget = self;
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
        self.sfTableViewManager.clickListenerTarget = self;
        self.sfTableViewManager.wkWebviewDelegate = self;
        [self fetchMoreRecommendations];
    }
    return self;
}

- (void)commonInitWithUrl:(NSString *)url
                   widgetID:(NSString *)widgetId
{
    self.widgetId = widgetId;
    self.url = url;
    self.outbrainSectionIndex = -1;
    self.smartFeedItemsArray = [[NSMutableArray alloc] init];
    self.customNibsForWidgetId = [[NSMutableDictionary alloc] init];
    self.reuseIdentifierWidgetId = [[NSMutableDictionary alloc] init];
}

-(NSInteger) smartFeedItemsCount {
    if (self.smartFeedItemsArray.count > 0) {
        return self.smartFeedItemsArray.count + 1; // plus header cell
    }
    else {
        return 0;
    }
}

#pragma mark - Fetch Recommendations
- (void) fetchMoreRecommendations {
    if (self.isLoading) {
        return;
    }
    
    if (self.feedCycleLimit > 0 && self.feedCycleCounter == self.feedCycleLimit) {
        return;
    }
    
    if (self.feedContentArray.count == 0 && self.smartFeedItemsArray.count > 0) { // a special case for smartfeed with only parent with no children
        return;
    }
        
    self.isLoading = YES;
    if (self.smartFeedItemsArray.count == 0 || self.feedContentArray == nil) {
        [self loadFirstTimeForFeed];
    }
    else {
        [self loadMoreAccordingToFeedContent];
    }
}

-(void) loadFirstTimeForFeed {
    OBRequest *request = [OBRequest requestWithURL:self.url widgetID:self.widgetId widgetIndex:self.outbrainIndex++];
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
            self.fid = [[response.responseRequest getNSNumberValueForPayloadKey:@"wnid"] stringValue];
            self.isRTL = response.settings.isRTL;
            self.feedCycleLimit = response.settings.feedCyclesLimit;
            if (self.feedContentArray == nil || self.feedCycleLimit == 0) {
                self.isSmartfeedWithNoChildren = YES;
            }
        }
        
        if (response.recommendations.count == 0) {
            NSLog(@"Error in fetchRecommendations - 0 recs for widget id: %@", request.widgetId);
            return;
        }
        
        // NSLog(@"loadFirstTimeForFeed received - %d recs, for widget id: %@", response.recommendations.count, request.widgetId);
        
        NSArray *parentSmartfeedItems = [self createSmartfeedItemsArrayFromResponse:response];
        [self loadMoreAccordingToFeedContent:parentSmartfeedItems];
    }];
}

-(void) loadMoreAccordingToFeedContent {
    [self loadMoreAccordingToFeedContent:nil];
}

-(void) loadMoreAccordingToFeedContent:(NSArray *)pendingItems {
    __block NSUInteger responseCount = 0;
    __block NSMutableArray *newSmartfeedItems = pendingItems ? [pendingItems mutableCopy] : [[NSMutableArray alloc] init];
    __block NSUInteger requestBatchSize = [self.feedContentArray count];
    for (NSString *widgetId in self.feedContentArray) {
        OBRequest *request = [OBRequest requestWithURL:self.url widgetID: widgetId widgetIndex:self.outbrainIndex++];
        request.fid = self.fid;
        if (self.externalID) {
            request.externalID = self.externalID;
        }
        [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
            responseCount++;
            
            if (response.error) {
                self.isLoading = NO;
                NSLog(@"Error in fetchRecommendations - %@, for widget id: %@", response.error.localizedDescription, request.widgetId);
                return;
            }
            
            if (response.recommendations.count == 0) {
                self.isLoading = NO;
                NSLog(@"Error in fetchRecommendations - 0 recs for widget id: %@", request.widgetId);
                return;
            }
            
          //  NSLog(@"fetchMoreRecommendations received - %d recs, for widget id: %@", response.recommendations.count, request.widgetId);
            
            [newSmartfeedItems addObjectsFromArray:[self createSmartfeedItemsArrayFromResponse:response]];
            if (responseCount == requestBatchSize) {
                [self reloadUIData: newSmartfeedItems];
            }
        }];
    }
    self.feedCycleCounter++;
}

-(NSArray *) createSmartfeedItemsArrayFromResponse:(OBRecommendationResponse *)response {
    NSString *widgetTitle = response.settings.widgetHeaderText;
    NSMutableArray *newSmartfeedItems = [[NSMutableArray alloc] init];
    for (OBRecommendation *rec in response.recommendations) {
        [[SFImageLoader sharedInstance] loadImageToCacheIfNeeded:rec.image.url];
    }
    
    if ([self isVideoIncludedInResponse:response] && response.recommendations.count == 1) {
        NSMutableDictionary *videoParams = [[NSMutableDictionary alloc] init];
        if (response.originalOBPayload[@"settings"]) {
            videoParams[@"settings"] = response.originalOBPayload[@"settings"];
        }
        if (response.originalOBPayload[@"request"]) {
            videoParams[@"request"] = response.originalOBPayload[@"request"];
        }
        
        NSURL *videoURL = [self appendParamsToVideoUrl: response];
        BOOL isParentResponse = response.settings.isSmartFeed;
        if (isParentResponse) {
            widgetTitle = nil;
        }
        SFItemData *item = [[SFItemData alloc] initWithVideoUrl:videoURL
                                                    videoParams:videoParams
                                           singleRecommendation:response.recommendations[0]
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
            break;
    }
   
    return newSmartfeedItems;
}

-(NSURL *) appendParamsToVideoUrl:(OBRecommendationResponse *)response {
    NSString *videoUrlStr = response.settings.videoUrl.absoluteString;
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:videoUrlStr];
    NSMutableArray *odbQueryItems = [[NSMutableArray alloc] initWithArray:components.queryItems];
    NSString *appNameStr = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    NSString *apiUserId = [OBAppleAdIdUtil isOptedOut] ? @"null" : [OBAppleAdIdUtil getAdvertiserId];
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"platform" value: @"ios"]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"inApp" value: @"true"]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"appName" value: appNameStr]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"appBundle" value: bundleIdentifier]];
    [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"deviceIfa" value: apiUserId]];
    if ([OutbrainManager sharedInstance].testMode) {
        [odbQueryItems addObject:[NSURLQueryItem queryItemWithName:@"testMode" value: @"true"]];
    }
    
    components.queryItems = odbQueryItems;
    return components.URL;
}

-(BOOL) isVideoIncludedInResponse:(OBRecommendationResponse *)response {
    BOOL videoIsIncludedInRequest = [[response.responseRequest getStringValueForPayloadKey:@"vid"] integerValue] == 1;
    BOOL videoURLIsIncludedInSettings = response.settings.videoUrl != nil;
    return videoIsIncludedInRequest && videoURLIsIncludedInSettings;
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
        return widgetHeader ? SFTypeCarouselWithTitle : SFTypeCarouselNoTitle;
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
    
    SFItemData *item = [[SFItemData alloc] initWithList:recommendations
                                            odbResponse:response
                                                   type:templateType];
    
    return @[item];
}

-(NSArray *) createGridItemsFromResponse:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
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
    
    BOOL shouldIncludeVideoInTheMiddle =
        [self isVideoIncludedInResponse:response] &&
        templateType == SFTypeGridTwoInRowNoTitle &&
        recommendations.count == 6;
    
    NSMutableArray *newSmartfeedItems = [[NSMutableArray alloc] init];
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    while (recommendationsMutableArray.count >= itemsPerRow) {
        NSRange subRange = NSMakeRange(0, itemsPerRow);
        NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
        [recommendationsMutableArray removeObjectsInRange:subRange];
        
        if (shouldIncludeVideoInTheMiddle &&
            newSmartfeedItems.count == 1)
        {
            // Add SFTypeGridTwoInRowWithVideo for the middle of the grid
            NSMutableDictionary *videoParams = [[NSMutableDictionary alloc] init];
            if (response.originalOBPayload[@"settings"]) {
                videoParams[@"settings"] = response.originalOBPayload[@"settings"];
            }
            if (response.originalOBPayload[@"request"]) {
                videoParams[@"request"] = response.originalOBPayload[@"request"];
            }
            
            NSURL *videoURL = [self appendParamsToVideoUrl: response];
            SFItemData *videoItem = [[SFItemData alloc] initWithVideoUrl:videoURL
                                                             videoParams:videoParams
                                                                 reclist:singleLineRecs
                                                             odbResponse:response
                                                                    type:SFTypeGridTwoInRowWithVideo];
            
            [newSmartfeedItems addObject:videoItem];
            continue;
        }
        
        SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs
                                                odbResponse:response
                                                       type:templateType];
        
        [newSmartfeedItems addObject:item];
    }

    return newSmartfeedItems;
}

-(void) reloadUIData:(NSArray *) newSmartfeedItems {
    // UX Optimization (derieved from Sky)
    // If Smartfeed is TableView (UX performance not so good) and we are about to update UI for relatively small number of items
    // and feedCycleLimit is set and we're not at the limit yet - let's postpone the reloadUI and loadMoreAccordingToFeedContent instead.
    if (self.sfTableViewManager && newSmartfeedItems.count < 5 && self.feedCycleLimit > 0 && self.feedCycleCounter < self.feedCycleLimit) {
        [self loadMoreAccordingToFeedContent:newSmartfeedItems];
        return;
    }
    
    self.isLoading = NO;
    
    NSMutableArray *indexPaths = [NSMutableArray array];
    // build the index paths for insertion
    // since you're adding to the end of datasource, the new rows will start at count
    for (int i = 0; i < newSmartfeedItems.count; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:self.smartFeedItemsArray.count+i inSection:self.outbrainSectionIndex]];
    }
    NSIndexPath *firstIdx = indexPaths[0];
    
    if (self.sfCollectionViewManager) {
        if (self.sfCollectionViewManager.collectionView != nil) {
            [self.sfCollectionViewManager.collectionView performBatchUpdates:^{
                [self.smartFeedItemsArray addObjectsFromArray:newSmartfeedItems];
                
                if (firstIdx.row == 0) {
                    [self.sfCollectionViewManager.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.outbrainSectionIndex]];
                }
                [self.sfCollectionViewManager.collectionView insertItemsAtIndexPaths:indexPaths];
                
            } completion:nil];
        }
    }
    else if (self.sfTableViewManager) {
        if (self.sfTableViewManager.tableView != nil) {
            // tell the table view to update (at all of the inserted index paths)
            UITableView *tableView = self.sfTableViewManager.tableView;
            [self.smartFeedItemsArray addObjectsFromArray:newSmartfeedItems];
            [UIView performWithoutAnimation:^{
                [tableView reloadData];
                [tableView beginUpdates];
                [tableView endUpdates];
            }];
        }
    }
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return nil;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header cell
        if (self.smartFeedHeadercCustomUIReuseIdentifier) {
            return [self.sfTableViewManager.tableView dequeueReusableCellWithIdentifier:self.smartFeedHeadercCustomUIReuseIdentifier forIndexPath:indexPath];
        }
        return [self.sfTableViewManager tableView:tableView headerCellForRowAtIndexPath:indexPath isRTL:self.isRTL];
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    UINib *singleItemCellNib = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *singleCellIdentifier = self.reuseIdentifierWidgetId[sfItem.widgetId];
    if (singleItemCellNib) {
        UIView *rootView = [[singleItemCellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        if (![rootView isKindOfClass:[UITableViewCell class]]) {
            NSLog([NSString stringWithFormat:@"Nib for reuseIdentifier (%@) is not type of UITableViewCell. --> reverting back to default", singleCellIdentifier]);
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
    return self.smartFeedItemsArray.count > 0 ? self.outbrainSectionIndex + 1 : self.outbrainSectionIndex;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header
        [self configureSmartFeedHeaderTableViewCell:cell atIndexPath:indexPath];
        return;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    // Report Viewability
    [[OBViewabilityService sharedInstance] reportRecsShownForRequest:sfItem.request];
    
    if ([cell isKindOfClass:[SFHorizontalWithVideoTableViewCell class]]) {
        [self configureHorizontalVideoTableViewCell:cell atIndexPath:indexPath];
    }
    else if ([cell isKindOfClass:[SFHorizontalTableViewCell class]]) {
        [self configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)cell atIndexPath:indexPath];
        if (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle) {
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
    
    if ((indexPath.row == (self.smartFeedItemsArray.count - 4)) || (self.smartFeedItemsArray.count < 6)) {
        [self fetchMoreRecommendations];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // Smartfeed header
        return UITableViewAutomaticDimension;
    }
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return [self.sfTableViewManager heightForRowAtIndexPath:indexPath withSFItem:sfItem];
}

- (void) configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)horizontalCell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalCell.horizontalView withCellTitleLabel:horizontalCell.titleLabel sfItem:sfItem];
    dispatch_async(dispatch_get_main_queue(), ^{
        // reload cells again because the first render always displays the wrong size.
        [horizontalCell.horizontalView setupView];
        [horizontalCell.horizontalView.collectionView reloadData];
        
        if (self.isTransparentBackground) {
            horizontalCell.horizontalView.backgroundColor = UIColor.clearColor;
            horizontalCell.horizontalView.collectionView.backgroundColor = UIColor.clearColor;
        } else {
            horizontalCell.horizontalView.backgroundColor = UIColor.whiteColor;
            horizontalCell.horizontalView.collectionView.backgroundColor = UIColor.whiteColor;
        }
    });
}

- (void) configureHorizontalVideoTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalWithVideoTableViewCell *horizontalVideoCell = (SFHorizontalWithVideoTableViewCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalVideoCell.horizontalView withCellTitleLabel:horizontalVideoCell.titleLabel sfItem:sfItem];
    
    BOOL shouldReturn = [SFUtils configureGenericVideoCell:horizontalVideoCell sfItem:sfItem];
    if (shouldReturn) {
        return;
    }
    
    horizontalVideoCell.webview = [SFUtils createVideoWebViewInsideView:horizontalVideoCell.horizontalView withSFItem:sfItem scriptMessageHandler:horizontalVideoCell.wkScriptMessageHandler uiDelegate:self withHorizontalMargin:YES];
    
    if (self.isTransparentBackground) {
        horizontalVideoCell.horizontalView.backgroundColor = UIColor.clearColor;
        horizontalVideoCell.horizontalView.collectionView.backgroundColor = UIColor.clearColor;
    } else {
        horizontalVideoCell.horizontalView.backgroundColor = UIColor.whiteColor;
        horizontalVideoCell.horizontalView.collectionView.backgroundColor = UIColor.whiteColor;
    }
    
    [SFUtils loadRequestIn:horizontalVideoCell sfItem:sfItem];
}

-(void) commonConfigureHorizontalCell:(SFHorizontalView *)horizontalView withCellTitleLabel:(UILabel *)cellTitleLabel sfItem:(SFItemData *)sfItem {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *horizontalItemCellNib = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *horizontalCellIdentifier = self.reuseIdentifierWidgetId[sfItem.widgetId];
    
    if (horizontalItemCellNib) {
        UIView *rootView = [[horizontalItemCellNib instantiateWithOwner:self options:nil] objectAtIndex:0];
        if (![rootView isKindOfClass:[UICollectionViewCell class]]) {
            NSLog([NSString stringWithFormat:@"Nib for reuseIdentifier (%@) is not type of UICollectionViewCell. --> reverting back to default", horizontalCellIdentifier]);
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
        [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: horizontalCellIdentifier];
    }
    else { // default UI
        if (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle) { // carousel
            horizontalItemCellNib = [UINib nibWithNibName:@"SFHorizontalItemCell" bundle:bundle];
            [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFHorizontalItemCell"];
        }
        else { // SFHorizontalFixed
            horizontalItemCellNib = [UINib nibWithNibName:@"SFHorizontalFixedItemCell" bundle:bundle];
            [horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: @"SFHorizontalFixedItemCell"];
        }
    }
    
    horizontalView.outbrainRecs = sfItem.outbrainRecs;
    horizontalView.settings = sfItem.odbSettings;
    horizontalView.shadowColor = sfItem.shadowColor;
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
}

- (void) configureSmartFeedHeaderTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:1 inSection:self.outbrainSectionIndex]];
    SFTableViewHeaderCell *sfHeaderCell = (SFTableViewHeaderCell *)cell;
    if (sfItem.widgetTitle) {
        sfHeaderCell.headerLabel.text = sfItem.widgetTitle;
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
    UINib *singleItemCellNib = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *singleCellIdentifier = self.reuseIdentifierWidgetId[sfItem.widgetId];
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
            return CGSizeMake(collectionView.frame.size.width, 50);
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
        
        [self.sfCollectionViewManager configureSmartfeedHeaderCell:cell atIndexPath:indexPath withTitle:sfItem.widgetTitle isSmartfeedWithNoChildren:self.isSmartfeedWithNoChildren];
        return;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    // Report Viewability
    [[OBViewabilityService sharedInstance] reportRecsShownForRequest:sfItem.request];
    
    if ([cell isKindOfClass:[SFHorizontalWithVideoCollectionViewCell class]]) {
        [self configureHorizontalVideoCollectionCell:cell atIndexPath:indexPath];
    }
    else if ([cell isKindOfClass:[SFHorizontalCollectionViewCell class]]) {
        [self configureHorizontalCell:cell atIndexPath:indexPath];
        if (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle) {
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
    
    if (indexPath.row == self.smartFeedItemsArray.count - 2) {
        [self fetchMoreRecommendations];
    }
}

- (SFItemData *) itemForIndexPath:(NSIndexPath *)indexPath {
    return self.smartFeedItemsArray[indexPath.row-1];
}
    
- (void) configureHorizontalCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalCollectionViewCell *horizontalCell = (SFHorizontalCollectionViewCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    [self commonConfigureHorizontalCell:horizontalCell.horizontalView withCellTitleLabel:horizontalCell.titleLabel sfItem:sfItem];
    
    if (self.isTransparentBackground) {
        horizontalCell.horizontalView.backgroundColor = UIColor.clearColor;
        horizontalCell.horizontalView.collectionView.backgroundColor = UIColor.clearColor;
        horizontalCell.cellView.backgroundColor = UIColor.clearColor;
    } else {
        horizontalCell.horizontalView.backgroundColor = UIColor.whiteColor;
        horizontalCell.horizontalView.collectionView.backgroundColor = UIColor.whiteColor;
        horizontalCell.cellView.backgroundColor = UIColor.whiteColor;
    }
}

- (void) configureHorizontalVideoCollectionCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalWithVideoCollectionViewCell *horizontalVideoCell = (SFHorizontalWithVideoCollectionViewCell *)cell;
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    [self commonConfigureHorizontalCell:horizontalVideoCell.horizontalView withCellTitleLabel:horizontalVideoCell.titleLabel sfItem:sfItem];
    
    
    BOOL shouldReturn = [SFUtils configureGenericVideoCell:horizontalVideoCell sfItem:sfItem];
    if (shouldReturn) {
        return;
    }
    
    if (self.isTransparentBackground) {
        horizontalVideoCell.horizontalView.backgroundColor = UIColor.clearColor;
        horizontalVideoCell.horizontalView.collectionView.backgroundColor = UIColor.clearColor;
        horizontalVideoCell.cellView.backgroundColor = UIColor.clearColor;
    } else {
        horizontalVideoCell.horizontalView.backgroundColor = UIColor.whiteColor;
        horizontalVideoCell.horizontalView.collectionView.backgroundColor = UIColor.whiteColor;
        horizontalVideoCell.cellView.backgroundColor = UIColor.whiteColor;
    }
    
    horizontalVideoCell.webview = [SFUtils createVideoWebViewInsideView:horizontalVideoCell.horizontalView withSFItem:sfItem scriptMessageHandler:horizontalVideoCell.wkScriptMessageHandler uiDelegate:self withHorizontalMargin:YES];
    
    [SFUtils loadRequestIn:horizontalVideoCell sfItem:sfItem];
}

#pragma mark - SFClickListener methods

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

#pragma mark - Common methods
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

- (void) setTransparentBackground: (BOOL)isTransparentBackground {
    self.isTransparentBackground = isTransparentBackground;
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (navigationAction.targetFrame == nil) {
        NSLog(@"SmartFeedManager createWebViewWith URL: %@", navigationAction.request.URL);
        if (self.delegate != nil && navigationAction.request.URL != nil) {
            [self.delegate userTappedOnVideoRec:navigationAction.request.URL];
        }
    }
    return nil;
}

@end
