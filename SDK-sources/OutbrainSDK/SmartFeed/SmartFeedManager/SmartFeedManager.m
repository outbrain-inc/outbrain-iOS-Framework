//
//  SmartFeedManager.m
//  ios-SmartFeed
//
//  Created by oded regev on 2/1/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SmartFeedManager.h"
#import "SFHorizontalCollectionViewCell.h"
#import "SFCollectionViewCell.h"
#import "SFTableViewCell.h"
#import "SFHorizontalTableViewCell.h"
#import "SFUtils.h"
#import "SFItemData.h"
#import "SFImageLoader.h"
#import "SFCollectionViewManager.h"
#import "SFTableViewManager.h"

#import <OutbrainSDK/OutbrainSDK.h>

@interface SmartFeedManager() <SFClickListener>

@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) NSString * _Nullable widgetId;
@property (nonatomic, copy) NSString *publisherName;
@property (nonatomic, strong) UIImage *publisherImage;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, strong) NSString *fid;

@property (nonatomic, assign) NSInteger outbrainIndex;
@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, strong) SFCollectionViewManager *sfCollectionViewManager;
@property (nonatomic, strong) SFTableViewManager *sfTableViewManager;

@property (nonatomic, strong) NSMutableArray *smartFeedItemsArray;
@property (nonatomic, strong) NSMutableDictionary *nibsForCellType;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifierForCellType;

@end

@implementation SmartFeedManager


#pragma mark - init methods
- (id)init
{
    return [self initWithUrl:nil widgetID:nil collectionView:nil publisherName:nil publisherImage:nil];
}

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
             collectionView:(UICollectionView * _Nonnull)collectionView
              publisherName:(NSString * _Nonnull)publisherName
             publisherImage:(UIImage * _Nonnull)publisherImage
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        [self commonInitWithUrl:url widgetID:widgetId publisherName:publisherName publisherImage:publisherImage];

        self.sfCollectionViewManager = [[SFCollectionViewManager alloc] initWitCollectionView:collectionView];
        self.sfCollectionViewManager.clickListenerTarget = self;
    }
    return self;
}

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
                  tableView:(UITableView * _Nonnull)tableView
              publisherName:(NSString * _Nonnull)publisherName
             publisherImage:(UIImage * _Nonnull)publisherImage {
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        
        [self commonInitWithUrl:url widgetID:widgetId publisherName:publisherName publisherImage:publisherImage];
       
        self.sfTableViewManager = [[SFTableViewManager alloc] initWithTableView:tableView];
        self.sfTableViewManager.clickListenerTarget = self;
        [self fetchMoreRecommendations];
    }
    return self;
}

- (void)commonInitWithUrl:(NSString *)url
                   widgetID:(NSString *)widgetId
              publisherName:(NSString *)publisherName
             publisherImage:(UIImage *)publisherImage
{
    self.widgetId = widgetId;
    self.url = url;
    self.publisherName = publisherName;
    self.publisherImage = publisherImage;
    self.outbrainSectionIndex = 1;
    self.smartFeedItemsArray = [[NSMutableArray alloc] init];
    self.nibsForCellType = [[NSMutableDictionary alloc] init];
    self.reuseIdentifierForCellType = [[NSMutableDictionary alloc] init];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Organic, horizontal carousel item cell
    UINib *nib = [UINib nibWithNibName:@"SFHorizontalItemCell" bundle:bundle];
    [self registerNib:nib withCellWithReuseIdentifier:@"SFHorizontalItemCell" forType:CarouselItem];
    
    nib = [UINib nibWithNibName:@"SFHorizontalFixedItemCell" bundle:bundle];
    [self registerNib:nib withCellWithReuseIdentifier:@"SFHorizontalFixedItemCell" forType:GridTwoInRowNoTitle];
    [self registerNib:nib withCellWithReuseIdentifier:@"SFHorizontalFixedItemCell" forType:GridThreeInRowNoTitle];
}

#pragma mark - Fetch Recommendations
- (void) fetchMoreRecommendations {
    if (self.isLoading) {
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
        
        // First load should fetch the children as well
        [self loadMoreAccordingToFeedContent];
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
}

-(NSUInteger) addNewItemsToSmartFeedArray:(OBRecommendationResponse *)response {
    NSUInteger newItemsCount = 0;
    for (OBRecommendation *rec in response.recommendations) {
        [[SFImageLoader sharedInstance] loadImageToCacheIfNeeded:rec.image.url];
    }
    
    int random = arc4random() % 6;
    random = 4;
    
    switch (random) {
        case 0:
            return [self addSingleItemsToSmartFeedArray:response.recommendations templateType:SingleItem];
        case 1:
            return [self addCarouselItemsToSmartFeedArray:response.recommendations];
        case 2:
            return [self addGridItemsToSmartFeedArray:response.recommendations templateType:GridTwoInRowNoTitle itemsPerRow:2];
        case 3:
            return [self addGridItemsToSmartFeedArray:response.recommendations templateType:GridThreeInRowNoTitle itemsPerRow:3];
        case 4:
            return [self addSingleItemsToSmartFeedArray:response.recommendations templateType:StripWithTitle];
        case 5:
            return [self addSingleItemsToSmartFeedArray:response.recommendations templateType:StripWithThumbnail];
            
        default:
            break;
    }
   
    return newItemsCount;
}

-(NSUInteger) addSingleItemsToSmartFeedArray:(NSArray *)recommendations templateType:(SFItemType)templateType {
    NSUInteger newItemsCount = 0;
    for (OBRecommendation *rec in recommendations) {
        SFItemData *item = [[SFItemData alloc] initWithSingleRecommendation:rec type:templateType];
        [self.smartFeedItemsArray addObject:item];
        newItemsCount++;
    }
    return newItemsCount;
}

-(NSUInteger) addCarouselItemsToSmartFeedArray:(NSArray *)recommendations {
    SFItemData *item = [[SFItemData alloc] initWithList:recommendations type:CarouselItem];
    [self.smartFeedItemsArray addObject:item];
    return 1;
}

-(NSUInteger) addGridItemsToSmartFeedArray:(NSArray *)recommendations templateType:(SFItemType)templateType itemsPerRow:(NSUInteger)itemsPerRow {
    NSUInteger newItemsCount = 0;
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    while (recommendationsMutableArray.count >= itemsPerRow) {
        NSRange subRange = NSMakeRange(0, itemsPerRow);
        NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
        [recommendationsMutableArray removeObjectsInRange:subRange];
        SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs type:templateType];
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
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    return [self.sfTableViewManager tableView:tableView cellForRowAtIndexPath:indexPath sfItemType:sfItem.itemType];
}

- (NSInteger)numberOfSectionsInTableView {
    return self.smartFeedItemsArray.count > 0 ? self.outbrainSectionIndex + 1 : self.outbrainSectionIndex;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SFHorizontalTableViewCell class]]) {
        [self configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)cell atIndexPath:indexPath];
        if (sfItem.itemType == CarouselItem) {
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
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return [self.sfTableViewManager heightForRowAtIndexPath:indexPath withSFItem:sfItem];
}

- (void) configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)horizontalCell atIndexPath:(NSIndexPath *)indexPath {
    if (horizontalCell.titleLabel) {
        horizontalCell.titleLabel.text = [NSString stringWithFormat:@"More from %@", self.publisherName];
    }
    
    if (horizontalCell.publisherImageView) {
        horizontalCell.publisherImageView.image = self.publisherImage;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    NSString *cellKey = [self keyForCellType:sfItem.itemType];
    UINib *horizontalItemCellNib = [self.nibsForCellType objectForKey:cellKey];
    NSString *horizontalCellIdentifier = [self.reuseIdentifierForCellType objectForKey:cellKey];
    
    [horizontalCell.horizontalView registerNib: horizontalItemCellNib forCellWithReuseIdentifier: horizontalCellIdentifier];
    horizontalCell.horizontalView.outbrainRecs = [self recsForHorizontalCellAtIndexPath:indexPath];
    [horizontalCell.horizontalView setupView];
    
    
    [horizontalCell.horizontalView setOnClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
}

- (void) configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath: indexPath];
    [self.sfTableViewManager configureSingleTableViewCell:cell atIndexPath:indexPath withSFItem:sfItem publisherName:self.publisherName];
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return [self.sfCollectionViewManager collectionView:collectionView cellForItemAtIndexPath:indexPath sfItemType:sfItem.itemType];
}

- (NSInteger)numberOfSectionsInCollectionView {
    return self.smartFeedItemsArray.count > 0 ? self.outbrainSectionIndex + 1 : self.outbrainSectionIndex;
}

- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView
                  layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    
    if (indexPath.section == self.outbrainSectionIndex) {
        SFItemData *sfItem = [self itemForIndexPath:indexPath];
        return [self.sfCollectionViewManager collectionView:collectionView sizeForItemAtIndexPath:indexPath sfItemType:sfItem.itemType];
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
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    if ([cell isKindOfClass:[SFHorizontalCollectionViewCell class]]) {
        [self configureHorizontalCell:cell atIndexPath:indexPath];
        if (sfItem.itemType == CarouselItem) {
            [SFUtils addDropShadowToView: cell]; // add shadow
        }
    }
    else { // SFSingleCell
        [self.sfCollectionViewManager configureSingleCell:cell atIndexPath:indexPath withSFItem:sfItem publisherName:self.publisherName];
    }
    
    if (indexPath.row == self.smartFeedItemsArray.count - 2) {
        [self fetchMoreRecommendations];
    }
}

- (SFItemData *) itemForIndexPath:(NSIndexPath *)indexPath {
    return self.smartFeedItemsArray[indexPath.row];
}

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return sfItem.outbrainRecs;
}
    
- (void) configureHorizontalCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalCollectionViewCell *horizontalCell = (SFHorizontalCollectionViewCell *)cell;
    if (horizontalCell.titleLabel) {
        horizontalCell.titleLabel.text = [NSString stringWithFormat:@"More from %@", self.publisherName];
    }
    
    if (horizontalCell.publisherImageView) {
        horizontalCell.publisherImageView.image = self.publisherImage;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    NSString *cellKey = [self keyForCellType:sfItem.itemType];
    UINib *horizontalItemCellNib = [self.nibsForCellType objectForKey:cellKey];
    NSString *horizontalCellIdentifier = [self.reuseIdentifierForCellType objectForKey:cellKey];
    [horizontalCell.horizontalView registerNib:horizontalItemCellNib forCellWithReuseIdentifier: horizontalCellIdentifier];
    horizontalCell.horizontalView.outbrainRecs = [self recsForHorizontalCellAtIndexPath:indexPath];
    [horizontalCell.horizontalView setupView];
    [horizontalCell.horizontalView setOnClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
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

- (void) registerNib:(UINib * _Nonnull )nib withCellWithReuseIdentifier:( NSString * _Nonnull )identifier forType:(SFItemType)type {
    NSString *key = [self keyForCellType:type];
    self.nibsForCellType[key] = nib;
    self.reuseIdentifierForCellType[key] = identifier;
}

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    if (self.sfCollectionViewManager != nil) {
        [self.sfCollectionViewManager registerSingleItemNib:nib forCellWithReuseIdentifier:identifier];
    }
    else {
        [self.sfTableViewManager registerSingleItemNib:nib forCellWithReuseIdentifier:identifier];
    }
}

@end
