//
//  SmartFeedManager.m
//  ios-SmartFeed
//
//  Created by oded regev on 2/1/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SmartFeedManager.h"
#import "SFHorizontalCell.h"
#import "SFCollectionViewCell.h"
#import "SFTableViewCell.h"
#import "SFHorizontalTableViewCell.h"
#import "SFUtils.h"

#import <OutbrainSDK/OutbrainSDK.h>

@interface SmartFeedManager() <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *widgetId;
@property (nonatomic, strong) NSMutableArray *outbrainRecs;
@property (nonatomic, assign) NSInteger outbrainIndex;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UITableView* tableView;

@property (nonatomic, copy) NSString *singleCellIdentifier;
@property (nonatomic, copy) NSString *horizontalCellIdentifier;
@property (nonatomic, strong) UINib *horizontalItemCellNib;

@end

@implementation SmartFeedManager

#pragma mark - init methods
- (id)init
{
    return [self initWithUrl:nil widgetID:nil collectionView:nil];
}

- (id)initWithUrl:(NSString *)url widgetID:(NSString *)widgetId collectionView:(UICollectionView *)collectionView;
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        self.widgetId = widgetId;
        self.url = url;
        self.outbrainRecs = [[NSMutableArray alloc] init];
        self.collectionView = collectionView;
        [collectionView registerClass:[SFHorizontalCell class] forCellWithReuseIdentifier:@"SFHorizontalCell"];
    }
    return self;
}

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url widgetID:(NSString * _Nonnull)widgetId tableView:(UITableView * _Nonnull)tableView {
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        self.widgetId = widgetId;
        self.url = url;
        self.outbrainRecs = [[NSMutableArray alloc] init];
        self.tableView = tableView;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalTableViewCell" bundle:bundle];
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: @"SFHorizontalCell"];
        
        [self fetchMoreRecommendations];
    }
    return self;
}

#pragma mark - Fetch Recommendations
- (void) fetchMoreRecommendations {
    if (self.isLoading) {
        return;
    }
    
    if (self.outbrainRecs.count > 12) return; //TODO temp code
        
    self.isLoading = YES;
    OBRequest *request = [OBRequest requestWithURL:self.url widgetID:self.widgetId widgetIndex:self.outbrainIndex++];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        self.isLoading = NO;
        if (response.error) {
            NSLog(@"Error in fetchRecommendations - %@", response.error.localizedDescription);
            return;
        }
        if (response.recommendations.count == 0) {            
            NSLog(@"Error in fetchRecommendations - 0 recs");
            return;
        }
        NSLog(@"fetchMoreRecommendations received - %d recs", response.recommendations.count);
        [self.outbrainRecs addObjectsFromArray:response.recommendations];
        [self reloadUIData];        
    }];
}

-(void) reloadUIData {
    if (self.collectionView != nil) {
        [self.collectionView reloadData];
    }
    if (self.tableView != nil) {
        [self.tableView reloadData];
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
        SFTableViewCell *singleCell = (SFTableViewCell *)cell;
        const NSInteger cellTag = indexPath.row;
        singleCell.tag = cellTag;
        singleCell.contentView.tag = cellTag;
        OBRecommendation *rec = [self recForIndexPath: indexPath];
        singleCell.recTitleLabel.text = rec.content;
        if ([rec isPaidLink]) {
            singleCell.recSourceLabel.text = [NSString stringWithFormat:@"Sponsored | %@", rec.source];
        }
        else {
            singleCell.recSourceLabel.text = rec.source;
        }
        
        /*
        dispatch_async(dispatch_get_global_queue(0,0), ^{
            NSData * data = [[NSData alloc] initWithContentsOfURL: rec.image.url];
            if ( data == nil )
                return;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (singleCell.tag != cellTag) {
                    return;
                }
                singleCell.recImageView.image = [UIImage imageWithData: data];
            });
        });
         */
        
        
        [SFUtils addDropShadowToView: singleCell];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
        tapGesture.numberOfTapsRequired = 1;
        [tapGesture setDelegate:self];
        [singleCell.contentView addGestureRecognizer:tapGesture];
    }
    
    if (indexPath.row == self.outbrainRecs.count - 2) {
        [self fetchMoreRecommendations];
    }
}

- (void) configureHorizontalTableViewCell:(SFHorizontalTableViewCell *)horizontalCell atIndexPath:(NSIndexPath *)indexPath {
    [horizontalCell.horizontalView registerNib:self.horizontalItemCellNib forCellWithReuseIdentifier: self.horizontalCellIdentifier];
    [horizontalCell.horizontalView setupView];
    horizontalCell.horizontalView.outbrainRecs = [self recsForHorizontalCellAtIndexPath:indexPath];
    [horizontalCell.horizontalView setOnClick:^(OBRecommendation *rec) {
        if (self.delegate != nil) {
            [self.delegate userTappedOnRecommendation:rec];
        }
    }];
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

- (void) collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && self.outbrainRecs.count == 0) {
        [self fetchMoreRecommendations];
        return;
    }
    
    if (indexPath.section == 1) {
        if ([cell isKindOfClass:[SFHorizontalCell class]]) {
            [self configureHorizontalCell:cell atIndexPath:indexPath];
        }
        else { // SFSingleCell
            SFCollectionViewCell *singleCell = (SFCollectionViewCell *)cell;
            const NSInteger cellTag = indexPath.row;
            singleCell.tag = cellTag;
            singleCell.contentView.tag = cellTag;
            OBRecommendation *rec = [self recForIndexPath: indexPath];
            singleCell.recTitleLabel.text = rec.content;
            
            if ([rec isPaidLink]) {
                singleCell.recSourceLabel.text = [NSString stringWithFormat:@"Sponsored | %@", rec.source];
            }
            else {
                singleCell.recSourceLabel.text = rec.source;
            }
            
            dispatch_async(dispatch_get_global_queue(0,0), ^{
                NSData * data = [[NSData alloc] initWithContentsOfURL: rec.image.url];
                if ( data == nil )
                    return;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (singleCell.tag != cellTag) {
                        return;
                    }
                    singleCell.recImageView.image = [UIImage imageWithData: data];
                });
            });
            
        
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapGesture:)];
            tapGesture.numberOfTapsRequired = 1;
            [tapGesture setDelegate:self];
            [singleCell.contentView addGestureRecognizer:tapGesture];
        }
        
        if (indexPath.row == self.outbrainRecs.count - 2) {
            [self fetchMoreRecommendations];
        }
    }
}

- (void) tapGesture: (id)sender
{
    UITapGestureRecognizer *gestureRec = sender;
    OBRecommendation *rec = [self recForIndexPath:[NSIndexPath indexPathForRow:gestureRec.view.tag inSection:1]];
    NSLog(@"tapGesture: %@", rec.content);
}

- (OBRecommendation *) recForIndexPath:(NSIndexPath *)indexPath {
    //TODO implement logic here
    return self.outbrainRecs[indexPath.row % self.outbrainRecs.count];
}

- (NSArray *) recsForHorizontalCellAtIndexPath:(NSIndexPath *)indexPath {
    //TODO implement logic here
    NSMutableArray *recs = [[NSMutableArray alloc] init];
    [recs addObject:self.outbrainRecs[0]];
    [recs addObject:self.outbrainRecs[1]];
    [recs addObject:self.outbrainRecs[2]];
    return recs;
}

- (void) configureHorizontalCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    SFHorizontalCell *horizontalCell = (SFHorizontalCell *)cell;
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
    return indexPath.section == 1 && ((indexPath.row % 3) == 2);
}

@end
