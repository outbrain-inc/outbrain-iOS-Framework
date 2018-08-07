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

#import <OutbrainSDK/OutbrainSDK.h>

@interface SmartFeedManager() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString * _Nullable url;
@property (nonatomic, strong) NSString * _Nullable widgetId;
@property (nonatomic, copy) NSString *publisherName;
@property (nonatomic, strong) UIImage *publisherImage;
@property (nonatomic, strong) NSArray *feedContentArray;
@property (nonatomic, strong) NSString *fid;

@property (nonatomic, assign) NSInteger outbrainIndex;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UITableView* tableView;

@property (nonatomic, strong) NSMutableArray *smartFeedItemsArray;
@property (nonatomic, strong) NSMutableDictionary *nibsForCellType;
@property (nonatomic, strong) NSMutableDictionary *reuseIdentifierForCellType;

@end

@implementation SmartFeedManager

const CGFloat kTableViewRowHeight = 250.0;

const NSString *kCollectionViewSingleReuseId = @"SFCollectionViewCell";
const NSString *kCollectionViewHorizontalCarouselReuseId = @"SFHorizontalCarouselCollectionViewCell";
const NSString *kCollectionViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleCollectionViewCell";
const NSString *kCollectionViewSingleWithTitleReuseId = @"SFSingleWithTitleCollectionViewCell";
const NSString *kCollectionViewSingleWithThumbnailReuseId = @"SFSingleWithThumbnailCollectionCell";

const NSString *kTableViewSingleReuseId = @"SFTableViewCell";
const NSString *kTableViewHorizontalCarouselReuseId = @"SFHorizontalTableViewCell";
const NSString *kTableViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleTableViewCell";
const NSString *kTableViewSingleWithTitleReuseId = @"SFSingleWithTitleTableViewCell";
const NSString *kTableViewSingleWithThumbnailReuseId = @"SFSingleWithThumbnailTableCell";

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
        
        self.collectionView = collectionView;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        // horizontal cells
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCarouselCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalCarouselCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalCarouselReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedNoTitleCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedNoTitleCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalFixedNoTitleReuseId];
        
        // Single item cell
        UINib *collectionViewCellNib = [UINib nibWithNibName:@"SFCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"collectionViewCellNib should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleReuseId];
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleWithTitleCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleWithTitleCollectionViewCell should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleWithTitleReuseId];
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleWithThumbnailCollectionCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleWithThumbnailCollectionCell should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailReuseId];
        
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
       
        self.tableView = tableView;
        tableView.estimatedRowHeight = kTableViewRowHeight;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        // horizontal cell (carousel container) SFCarouselContainerCell
        // horizontal cells
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalCarouselReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedNoTitleTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedNoTitleTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalFixedNoTitleReuseId];
        
        // single item cell
        UINib *nib = [UINib nibWithNibName:@"SFTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleWithTitleTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleWithTitleTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleWithTitleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleWithThumbnailTableCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleWithThumbnailTableCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleWithThumbnailReuseId];
        
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
    
    int random = arc4random() % 3;
    random = 3;
    
    switch (random) {
        case 0:
            return [self addSingleItemsToSmartFeedArray:response.recommendations templateType:SingleItem];
        case 1:
            return [self addCarouselItemsToSmartFeedArray:response.recommendations];
        case 2:
            return [self addGridItemsToSmartFeedArray:response.recommendations];
        case 3:
            return [self addSingleItemsToSmartFeedArray:response.recommendations templateType:StripWithTitle];
        case 4:
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

-(NSUInteger) addGridItemsToSmartFeedArray:(NSArray *)recommendations {
    NSUInteger newItemsCount = 0;
    NSMutableArray *recommendationsMutableArray = [recommendations mutableCopy];
    while (recommendationsMutableArray.count >= 2) {
        NSRange subRange = NSMakeRange(0, 2);
        NSArray *singleLineRecs = [recommendationsMutableArray subarrayWithRange:subRange];
        [recommendationsMutableArray removeObjectsInRange:subRange];
        SFItemData *item = [[SFItemData alloc] initWithList:singleLineRecs type:GridTwoInRowNoTitle];
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
    
    if (self.collectionView != nil) {
        //[self.collectionView reloadData];
        [self.collectionView performBatchUpdates:^{
            if (currentCount == 0) {
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:self.outbrainSectionIndex]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        } completion:nil];
    }
    
    if (self.tableView != nil) {
        // tell the table view to update (at all of the inserted index paths)
        [self.tableView beginUpdates];
        if (currentCount == 0) {
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:self.outbrainSectionIndex] withRowAnimation:UITableViewRowAnimationNone];
        }
        else {
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
        }
        
        [self.tableView endUpdates];
    }
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section != self.outbrainSectionIndex) {
        return nil;
    }
    
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    
    switch (sfItem.itemType) {
        case SingleItem:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewSingleReuseId forIndexPath:indexPath];
        case CarouselItem:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalCarouselReuseId forIndexPath:indexPath];
        case GridTwoInRowNoTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalFixedNoTitleReuseId forIndexPath:indexPath];
        case StripWithTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleWithTitleReuseId forIndexPath:indexPath];
        case StripWithThumbnail:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleWithThumbnailReuseId forIndexPath:indexPath];
            
        default:
            NSAssert(false, @"sfItem.itemType must be covered in this switch/case statement");
            return [[UITableViewCell alloc] init];
    }
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
        [self configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:indexPath];
    }
    
    if ((indexPath.row == (self.smartFeedItemsArray.count - 4)) || (self.smartFeedItemsArray.count < 6)) {
        [self fetchMoreRecommendations];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    if (sfItem.itemType == StripWithThumbnail) {
        return 120.0;
    }
    else if (sfItem.itemType == StripWithTitle) {
        return 280.0;
    }
    
    return kTableViewRowHeight;
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
    [horizontalCell.horizontalView setupView];
    horizontalCell.horizontalView.outbrainRecs = [self recsForHorizontalCellAtIndexPath:indexPath];
    
    [horizontalCell.horizontalView setOnClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
}

- (void) configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFTableViewCell *singleCell = (SFTableViewCell *)cell;
    const NSInteger cellTag = indexPath.row;
    singleCell.tag = cellTag;
    singleCell.contentView.tag = cellTag;
    SFItemData *sfItem = [self itemForIndexPath: indexPath];
    OBRecommendation *rec = sfItem.singleRec;
    singleCell.recTitleLabel.text = rec.content;
    if ([rec isPaidLink]) {
        singleCell.recSourceLabel.text = [NSString stringWithFormat:@"Sponsored | %@", rec.source];
        if ([rec shouldDisplayDisclosureIcon]) {
            singleCell.adChoicesButton.hidden = NO;
            singleCell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            singleCell.adChoicesButton.tag = cellTag;
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            UIImage *adChoicesImage = [UIImage imageNamed:@"adchoices-icon" inBundle:bundle compatibleWithTraitCollection:nil];
            [singleCell.adChoicesButton setImage:adChoicesImage forState:UIControlStateNormal];
            [singleCell.adChoicesButton addTarget:self action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            singleCell.adChoicesButton.hidden = YES;
        }
    }
    else {
        singleCell.recSourceLabel.text = rec.source;
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:singleCell.recImageView];
    
    // add shadow
    if (sfItem.itemType == StripWithTitle) {
        //[SFUtils addDropShadowToView: singleCell.cardContentView];
    }
    else {
        [SFUtils addDropShadowToView: singleCell];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    [singleCell.contentView addGestureRecognizer:tapGesture];
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    switch (sfItem.itemType) {
        case SingleItem:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleReuseId forIndexPath:indexPath];
        case CarouselItem:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalCarouselReuseId forIndexPath:indexPath];
        case GridTwoInRowNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalFixedNoTitleReuseId forIndexPath:indexPath];
        case StripWithTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithTitleReuseId forIndexPath:indexPath];
        case StripWithThumbnail:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailReuseId forIndexPath:indexPath];
            
        default:
            break;
    }
}

- (NSInteger)numberOfSectionsInCollectionView {
    return self.smartFeedItemsArray.count > 0 ? self.outbrainSectionIndex + 1 : self.outbrainSectionIndex;
}

- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView
                  layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath {
    
    CGFloat width = collectionView.frame.size.width;
    
    if (indexPath.section == self.outbrainSectionIndex) {
        SFItemData *sfItem = [self itemForIndexPath:indexPath];
        
        if (sfItem.itemType == GridTwoInRowNoTitle) {
            return CGSizeMake(width, 250.0);
        }
        else if (sfItem.itemType == StripWithTitle) {
            return CGSizeMake(width, 280.0);
        }
        else if (sfItem.itemType == StripWithThumbnail) {
            return CGSizeMake(width - 20.0, 120.0);
        }
        
        return CGSizeMake(width - 20.0, 250.0);
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
        [self configureSingleCell:cell atIndexPath:indexPath];
    }
    
    if (indexPath.row == self.smartFeedItemsArray.count - 2) {
        [self fetchMoreRecommendations];
    }
}

- (void) tapGesture: (id)sender
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

- (SFItemData *) itemForIndexPath:(NSIndexPath *)indexPath {
    return self.smartFeedItemsArray[indexPath.row];
}

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath {
    SFItemData *sfItem = [self itemForIndexPath:indexPath];
    return sfItem.outbrainRecs;
}

- (void) configureSingleCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFCollectionViewCell *singleCell = (SFCollectionViewCell *)cell;
    const NSInteger cellTag = indexPath.row;
    singleCell.tag = cellTag;
    singleCell.contentView.tag = cellTag;
    if (singleCell.cardContentView) {
        singleCell.cardContentView.tag = cellTag;
    }
    SFItemData *sfItem = [self itemForIndexPath: indexPath];
    OBRecommendation *rec = sfItem.singleRec;
    singleCell.recTitleLabel.text = rec.content;
    
    if ([rec isPaidLink]) {
        singleCell.recSourceLabel.text = [NSString stringWithFormat:@"Sponsored | %@", rec.source];
        if ([rec shouldDisplayDisclosureIcon]) {
            singleCell.adChoicesButton.hidden = NO;
            singleCell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            singleCell.adChoicesButton.tag = cellTag;
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            UIImage *adChoicesImage = [UIImage imageNamed:@"adchoices-icon" inBundle:bundle compatibleWithTraitCollection:nil];
            [singleCell.adChoicesButton setImage:adChoicesImage forState:UIControlStateNormal];
            [singleCell.adChoicesButton addTarget:self action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            singleCell.adChoicesButton.hidden = YES;
        }
    }
    else {
        singleCell.recSourceLabel.text = rec.source;
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:singleCell.recImageView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    
    // Cell Specific configuration
    if (sfItem.itemType == StripWithTitle) {
        [SFUtils addDropShadowToView: singleCell.cardContentView];
        const NSString *organicCellTitle = [NSString stringWithFormat:@"Around %@", self.publisherName];
        singleCell.cellTitleLabel.text = [rec isPaidLink] ? @"Sponsored Links" : organicCellTitle;
        singleCell.outbrainLabelingContainer.hidden = ![rec isPaidLink];
        singleCell.recTitleLabel.textColor = [rec isPaidLink] ? UIColorFromRGB(0x171717) : UIColorFromRGB(0x808080);
        [singleCell.outbrainLabelingContainer addTarget:self action:@selector(outbrainLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [singleCell.cardContentView addGestureRecognizer:tapGesture];
    }
    else {
        [SFUtils addDropShadowToView: singleCell];
        [singleCell.contentView addGestureRecognizer:tapGesture];
    }
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
    [horizontalCell.horizontalView setupView];
    horizontalCell.horizontalView.outbrainRecs = [self recsForHorizontalCellAtIndexPath:indexPath];
    [horizontalCell.horizontalView setOnClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
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
    if (self.collectionView != nil) {
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
    else {
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
}

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath {
    SFItemData *sfItem = self.smartFeedItemsArray[indexPath.row];
    return [sfItem outbrainRecs] && [sfItem outbrainRecs].count > 0;
}

@end
