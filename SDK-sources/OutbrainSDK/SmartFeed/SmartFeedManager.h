//
//  SmartFeedManager.h
//  ios-SmartFeed
//
//  Created by oded regev on 2/1/18.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

@protocol SmartFeedDelegate

-(void) userTappedOnRecommendation:(OBRecommendation *_Nonnull)rec;

@end


@interface SmartFeedManager : NSObject

- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url widgetID:(NSString * _Nonnull)widgetId collectionView:(UICollectionView * _Nonnull)collectionView;



- (void) fetchMoreRecommendations;

// TableView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url widgetID:(NSString * _Nonnull)widgetId tableView:(UITableView * _Nonnull)tableView;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// CollectionView
- (UICollectionViewCell *_Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void)collectionView:(UICollectionView * _Nonnull)collectionView
       willDisplayCell:(UICollectionViewCell * _Nonnull)cell
    forItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void) registerHorizontalItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

@property (nonatomic, strong, readonly) NSMutableArray *outbrainRecs;
@property (nonatomic, weak) id<SmartFeedDelegate> delegate;

@end
