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
#import "SFCollectionViewCell.h"
#import "SFTableViewCell.h"
#import "SFHorizontalTableViewCell.h"
#import "SFVideoCollectionViewCell.h"
#import "SFUtils.h"
#import "SFItemData.h"
#import "SFImageLoader.h"
#import "SFCollectionViewManager.h"
#import "SFTableViewManager.h"
#import <OutbrainSDK/OutbrainSDK.h>


@interface SmartFeedManager() <SFClickListener, WKUIDelegate>

@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) NSString * _Nullable widgetId;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, strong) NSString *fid;
@property (nonatomic, assign) NSInteger feedCycleCounter;
@property (nonatomic, assign) NSInteger feedCycleLimit;

@property (nonatomic, assign) NSInteger outbrainIndex;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) SFCollectionViewManager *sfCollectionViewManager;
@property (nonatomic, strong) SFTableViewManager *sfTableViewManager;

@property (nonatomic, strong) NSMutableArray *smartFeedItemsArray;
@property (nonatomic, strong) NSMutableDictionary *customNibsForWidgetId;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifierWidgetId;

@end

@implementation SmartFeedManager


#pragma mark - init methods
- (id)init
{
    return [self initWithUrl:nil widgetID:nil collectionView:nil];
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
        [self fetchMoreRecommendations];
    }
    return self;
}

- (void)commonInitWithUrl:(NSString *)url
                   widgetID:(NSString *)widgetId
{
    self.widgetId = widgetId;
    self.url = url;
    self.outbrainSectionIndex = 1;
    self.smartFeedItemsArray = [[NSMutableArray alloc] init];
    self.customNibsForWidgetId = [[NSMutableDictionary alloc] init];
    self.reuseIdentifierWidgetId = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoReadyNotification:)
                                                 name:@"VideoReadyNotification"
                                               object:nil];
}

- (void) videoReadyNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"VideoReadyNotification"]) {
        UIView *view = (UIView *) notification.object;
        NSLog (@"Successfully received the videoReady notification! - view.tag: %d", view.tag);
    }
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
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        self.isLoading = NO;
        if (response.error) {
            NSLog(@"Error in fetchRecommendations - %@, for widget id: %@", response.error.localizedDescription, request.widgetId);
            return;
        }
        
        if (response.settings.isSmartFeed == YES) {
            self.feedContentArray = response.settings.feedContentArray;
            self.fid = [[response.responseRequest getNSNumberValueForPayloadKey:@"wnid"] stringValue];
            self.feedCycleLimit = response.settings.feedCyclesLimit;
        }
        
        if (response.recommendations.count == 0) {
            NSLog(@"Error in fetchRecommendations - 0 recs for widget id: %@", request.widgetId);
            return;
        }
        
        // NSLog(@"loadFirstTimeForFeed received - %d recs, for widget id: %@", response.recommendations.count, request.widgetId);
        
        NSUInteger newItemsCount = 0;
        @synchronized(self) {
            newItemsCount = [self addNewItemsToSmartFeedArray:response];
        }
        [self reloadUIData: newItemsCount];
        
        // First load should fetch the children as well, if self.feedCycleLimit is set, we want to optimize
        // performance by loading all the cycles in straight away (usually it will be < 10 times).
        if (self.feedCycleLimit > 0 && self.feedCycleCounter < self.feedCycleLimit) {
            while (self.feedCycleCounter < self.feedCycleLimit) {
                [self loadMoreAccordingToFeedContent];
            }
        }
        else {
            [self loadMoreAccordingToFeedContent];
        }
    }];
}

-(void) loadMoreAccordingToFeedContent {
    __block NSUInteger newItemsCount = 0;
    __block NSUInteger responseCount = 0;
    __block NSUInteger requestBatchSize = [self.feedContentArray count];
    for (NSString *widgetId in self.feedContentArray) {
        OBRequest *request = [OBRequest requestWithURL:self.url widgetID: widgetId widgetIndex:self.outbrainIndex++];
        request.fid = self.fid;
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
            
            @synchronized(self) {
                newItemsCount += [self addNewItemsToSmartFeedArray:response];
            }
            
            if (responseCount == requestBatchSize) {
                self.isLoading = NO;
                [self reloadUIData: newItemsCount];
            }
        }];
    }
    self.feedCycleCounter++;
}

-(NSUInteger) addNewItemsToSmartFeedArray:(OBRecommendationResponse *)response {
    NSUInteger newItemsCount = 0;
    for (OBRecommendation *rec in response.recommendations) {
        [[SFImageLoader sharedInstance] loadImageToCacheIfNeeded:rec.image.url];
    }
    
    BOOL videoIncluded = response.settings.isSmartFeed; // TODO check in response if video is included
    if (videoIncluded) {
        NSURL *videoURL = [NSURL URLWithString:@"https://static-test.outbrain.com/video/app/vidgetInApp.html?platform=ios&widgetId=AR_1&publisherId=111&sourceId=222"];
        SFItemData *item = [[SFItemData alloc] initWithVideoUrl:videoURL widgetId:response.request.widgetId];
        [self.smartFeedItemsArray addObject:item];
        newItemsCount++;
    }
    
    SFItemType itemType = [self sfItemTypeFromResponse:response];
    NSString *widgetTitle = response.settings.widgetHeaderText;
    
   // itemType = SFTypeCarouselWithTitle;
    
    switch (itemType) {
        case SFTypeCarouselWithTitle:
        case SFTypeCarouselNoTitle:
            newItemsCount += [self addCarouselItemsToSmartFeedArray:response templateType:itemType widgetTitle:widgetTitle];
            break;
        case SFTypeGridTwoInRowNoTitle:
        case SFTypeGridTwoInRowWithTitle:
        case SFTypeGridThreeInRowNoTitle:
        case SFTypeGridThreeInRowWithTitle:
            newItemsCount += [self addGridItemsToSmartFeedArray:response templateType:itemType widgetTitle:widgetTitle];
            break;
        case SFTypeStripNoTitle:
        case SFTypeStripWithTitle:
        case SFTypeStripWithThumbnailNoTitle:
        case SFTypeStripWithThumbnailWithTitle:
            newItemsCount += [self addSingleItemsToSmartFeedArray:response templateType:itemType widgetTitle:widgetTitle];
            break;
        default:
            break;
    }
   
    return newItemsCount;
}

-(SFItemType) sfItemTypeFromResponse:(OBRecommendationResponse *)response {
    NSString *recMode = response.settings.recMode;
    NSString *widgetHeader = response.settings.widgetHeaderText;
    BOOL isParentResponse = response.settings.feedContentArray != nil;
    
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
    
    NSLog(@"recMode value is not currently covered in the SDK");
    return SFTypeStripWithTitle;
}

-(NSUInteger) addSingleItemsToSmartFeedArray:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;
    NSString *widgetId = response.request.widgetId;
    NSUInteger newItemsCount = 0;
    for (OBRecommendation *rec in recommendations) {
        SFItemData *item = [[SFItemData alloc] initWithSingleRecommendation:rec type:templateType widgetTitle:widgetTitle widgetId:widgetId];
        [self.smartFeedItemsArray addObject:item];
        newItemsCount++;
    }
    return newItemsCount;
}

-(NSUInteger) addCarouselItemsToSmartFeedArray:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;
    NSString *widgetId = response.request.widgetId;
    SFItemData *item = [[SFItemData alloc] initWithList:recommendations type:templateType widgetTitle:widgetTitle widgetId:widgetId];
    [self.smartFeedItemsArray addObject:item];
    return 1;
}

-(NSUInteger) addGridItemsToSmartFeedArray:(OBRecommendationResponse *)response templateType:(SFItemType)templateType widgetTitle:(NSString *)widgetTitle {
    NSArray *recommendations = response.recommendations;
    NSString *widgetId = response.request.widgetId;
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
    
    NSUInteger newItemsCount = 0;
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    while (recommendationsMutableArray.count >= itemsPerRow) {
        NSRange subRange = NSMakeRange(0, itemsPerRow);
        NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
        [recommendationsMutableArray removeObjectsInRange:subRange];
        SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs type:templateType widgetTitle:widgetTitle widgetId:widgetId];
        [self.smartFeedItemsArray addObject:item];
        newItemsCount++;
    }

    return newItemsCount;
}

-(void) reloadUIData:(NSUInteger) newItemsCount {
    NSInteger currentCount = self.smartFeedItemsArray.count - newItemsCount;
    NSMutableArray *indexPaths = [NSMutableArray array];
    // build the index paths for insertion
    // since you're adding to the end of datasource, the new rows will start at count
    for (int i = 0; i < newItemsCount; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:self.outbrainSectionIndex]];
    }

    if (self.sfCollectionViewManager) {
        [self.sfCollectionViewManager reloadUIData:currentCount indexPaths:indexPaths sectionIndex:self.outbrainSectionIndex];
    }
    else if (self.sfTableViewManager) {
        [self.sfTableViewManager reloadUIData:currentCount indexPaths:indexPaths sectionIndex:self.outbrainSectionIndex];
    }
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return nil;
    }
    
    if (indexPath.row == 0) {
        // Smartfeed header cell
        return [self.sfTableViewManager tableView:tableView headerCellForRowAtIndexPath:indexPath];
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    UINib *singleItemCellNib = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *singleCellIdentifier = self.reuseIdentifierWidgetId[sfItem.widgetId];
    if (singleItemCellNib && singleCellIdentifier && sfItem.singleRec) { // custom UI
        [self.sfTableViewManager.tableView registerNib:singleItemCellNib forCellReuseIdentifier:singleCellIdentifier];
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
    
    if ([cell isKindOfClass:[SFHorizontalTableViewCell class]]) {
        [self configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)cell atIndexPath:indexPath];
        if (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle) {
            [SFUtils addDropShadowToView: cell];
        }
    }
    else { // SFSingleCell
        [self configureSingleTableViewCell:cell atIndexPath:indexPath];        
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
}

-(void) commonConfigureHorizontalCell:(SFHorizontalView *)horizontalView withCellTitleLabel:(UILabel *)cellTitleLabel sfItem:(SFItemData *)sfItem {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    UINib *horizontalItemCellNib = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *horizontalCellIdentifier = self.reuseIdentifierWidgetId[sfItem.widgetId];
    
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

- (void) configureSingleTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath: indexPath];
    [self.sfTableViewManager configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:indexPath withSFItem:sfItem];
}

- (void) configureSmartFeedHeaderTableViewCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:[NSIndexPath indexPathForRow:1 inSection:self.outbrainSectionIndex]];
    SFTableViewHeaderCell *sfHeaderCell = (SFTableViewHeaderCell *)cell;
    if (sfItem.widgetTitle) {
        sfHeaderCell.headerOBLabel.text = sfItem.widgetTitle;
    }
    [Outbrain registerOBLabel:sfHeaderCell.headerOBLabel withWidgetId:self.widgetId andUrl:self.url];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(outbrainLabelClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [sfHeaderCell.contentView addGestureRecognizer:tapGesture];
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // Smartfeed header cell
        return [self.sfCollectionViewManager collectionView:collectionView headerCellForItemAtIndexPath:indexPath];
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    UINib *singleItemCellNib = self.customNibsForWidgetId[sfItem.widgetId];
    NSString *singleCellIdentifier = self.reuseIdentifierWidgetId[sfItem.widgetId];
    if (singleItemCellNib && singleCellIdentifier && sfItem.singleRec) { // custom UI
        [self.sfCollectionViewManager.collectionView registerNib:singleItemCellNib forCellWithReuseIdentifier:singleCellIdentifier];
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
        SFCollectionViewHeaderCell *sfHeaderCell = (SFCollectionViewHeaderCell *)cell;
        [Outbrain registerOBLabel:sfHeaderCell.headerOBLabel withWidgetId:self.widgetId andUrl:self.url];
        [self.sfCollectionViewManager configureSmartfeedHeaderCell:cell atIndexPath:indexPath withTitle:sfItem.widgetTitle];
        return;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SFHorizontalCollectionViewCell class]]) {
        [self configureHorizontalCell:cell atIndexPath:indexPath];
        if (sfItem.itemType == SFTypeCarouselWithTitle || sfItem.itemType == SFTypeCarouselNoTitle) {
            [SFUtils addDropShadowToView: cell]; // add shadow
        }
    }
    else if ([cell isKindOfClass:[SFVideoCollectionViewCell class]]) {
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
