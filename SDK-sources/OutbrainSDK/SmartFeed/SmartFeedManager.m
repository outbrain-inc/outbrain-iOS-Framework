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

@property (nonatomic, copy) NSString *singleCellIdentifier;
@property (nonatomic, copy) NSString *horizontalCellIdentifier;
@property (nonatomic, strong) UINib *horizontalItemCellNib;

@property (nonatomic, strong) NSMutableArray *smartFeedItemsArray;

@end

@implementation SmartFeedManager

const CGFloat kTableViewRowHeight = 250.0;

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
        
        // horizontal cell (carousel container) SFCarouselContainerCell
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"horizontalCellNib should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier:@"SFHorizontalCell"];
        
        // Paid, single item cell
        UINib *collectionViewCellNib = [UINib nibWithNibName:@"SFCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"collectionViewCellNib should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier:@"SFCollectionViewCell"];
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
        UINib *nib = [UINib nibWithNibName:@"SFHorizontalTableViewCell" bundle:bundle];
        [self.tableView registerNib:nib forCellReuseIdentifier: @"SFHorizontalCell"];
        
        // Paid, single item cell
        nib = [UINib nibWithNibName:@"SFTableViewCell" bundle:bundle];
        [self registerSingleItemNib:nib forCellWithReuseIdentifier:@"SFTableViewCell"];
        
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
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    // Organic, horizontal carousel item cell
    UINib *nib = [UINib nibWithNibName:@"SFHorizontalItemCell" bundle:bundle];
    [self registerHorizontalItemNib:nib forCellWithReuseIdentifier:@"SFHorizontalItemCell"];
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
    NSMutableArray *organicRecsList = [[NSMutableArray alloc] init];
    for (OBRecommendation *rec in response.recommendations) {
        [[SFImageLoader sharedInstance] loadImageToCacheIfNeeded:rec.image.url];
        if (rec.isPaidLink) {
            SFItemData *item = [[SFItemData alloc] initWithSingleRecommendation:rec];
            [self.smartFeedItemsArray addObject:item];
            newItemsCount++;
        }
        else {
            [organicRecsList addObject:rec];
        }
    }
    
    if (organicRecsList.count > 1) {
        SFItemData *item = [[SFItemData alloc] initWithList:organicRecsList];
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
    if ([self isHorizontalCell:indexPath]) {
        return [tableView dequeueReusableCellWithIdentifier:@"SFHorizontalCell" forIndexPath:indexPath];
    }
    else {
        return [tableView dequeueReusableCellWithIdentifier:self.singleCellIdentifier forIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {    
    if (indexPath.section == 0) {
        return;
    }
    
    if ([cell isKindOfClass:[SFHorizontalTableViewCell class]]) {
        [self configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)cell atIndexPath:indexPath];
        [SFUtils addDropShadowToView: cell];
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
    return kTableViewRowHeight;
}

- (void) configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)horizontalCell atIndexPath:(NSIndexPath *)indexPath {
    horizontalCell.moreFromLabel.text = [NSString stringWithFormat:@"More from %@", self.publisherName];
    horizontalCell.moreFromImageView.image = self.publisherImage;
    [horizontalCell.horizontalView registerNib:self.horizontalItemCellNib forCellWithReuseIdentifier: self.horizontalCellIdentifier];
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
    
    [SFUtils addDropShadowToView: singleCell];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    [singleCell.contentView addGestureRecognizer:tapGesture];
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHorizontalCell:indexPath]) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"SFHorizontalCell" forIndexPath:indexPath];
    }
    else {
        return [collectionView dequeueReusableCellWithReuseIdentifier: self.singleCellIdentifier forIndexPath:indexPath];
    }
}

- (NSInteger)numberOfSectionsInCollectionView {
    return self.smartFeedItemsArray.count > 0 ? self.outbrainSectionIndex + 1 : self.outbrainSectionIndex;
}

- (void) collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.smartFeedItemsArray.count == 0) {
        [self fetchMoreRecommendations];
        return;
    }
    
    if (indexPath.section == self.outbrainSectionIndex) {
        if ([cell isKindOfClass:[SFHorizontalCollectionViewCell class]]) {
            [self configureHorizontalCell:cell atIndexPath:indexPath];
            [SFUtils addDropShadowToView: cell]; // add shadow
        }
        else { // SFSingleCell
            [self configureSingleCell:cell atIndexPath:indexPath];
        }
        
        if (indexPath.row == self.smartFeedItemsArray.count - 2) {
            [self fetchMoreRecommendations];
        }
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
    [singleCell.contentView addGestureRecognizer:tapGesture];
    
    [SFUtils addDropShadowToView: singleCell]; // add shadow
}
    
- (void) configureHorizontalCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalCollectionViewCell *horizontalCell = (SFHorizontalCollectionViewCell *)cell;
    horizontalCell.moreFromLabel.text = [NSString stringWithFormat:@"More from %@", self.publisherName];
    horizontalCell.moreFromImageView.image = self.publisherImage;
    
    [horizontalCell.horizontalView registerNib:self.horizontalItemCellNib forCellWithReuseIdentifier: self.horizontalCellIdentifier];
    [horizontalCell.horizontalView setupView];
    horizontalCell.horizontalView.outbrainRecs = [self recsForHorizontalCellAtIndexPath:indexPath];
    [horizontalCell.horizontalView setOnClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
}

#pragma mark - Common methods
- (void) registerHorizontalItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    self.horizontalItemCellNib = nib;
    self.horizontalCellIdentifier = identifier;
}

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    self.singleCellIdentifier = identifier;
    if (self.collectionView != nil) {
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
    else {
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
}

-(BOOL) isHorizontalCell:(NSIndexPath *)indexPath {
    SFItemData *sfItem = self.smartFeedItemsArray[indexPath.row];
    return [sfItem itemType] == HorizontalItem;
}

@end
