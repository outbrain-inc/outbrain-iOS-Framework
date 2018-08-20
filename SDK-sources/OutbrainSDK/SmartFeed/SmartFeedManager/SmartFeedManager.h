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

-(void) userTappedOnAdChoicesIcon:(NSURL *_Nonnull)url;

-(void) userTappedOnOutbrainLabeling;

@end


@interface SmartFeedManager : NSObject

typedef enum
{
    SingleItem = 1,
    CarouselItem,
    GridTwoInRowNoTitle,
    GridThreeInRowNoTitle,
    StripWithTitle,
    StripWithThumbnail
} SFItemType;

@property (nonatomic, strong, readonly) NSString * _Nullable url;
@property (nonatomic, strong, readonly) NSString * _Nullable widgetId;
@property (nonatomic, assign) NSInteger outbrainSectionIndex;
@property (nonatomic, strong, readonly) NSMutableArray *smartFeedItemsArray;

@property (nonatomic, weak) id<SmartFeedDelegate> delegate;

// TableView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
                  tableView:(UITableView * _Nonnull)tableView;


- (NSInteger)numberOfSectionsInTableView;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// CollectionView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
             collectionView:(UICollectionView * _Nonnull)collectionView;

- (NSInteger)numberOfSectionsInCollectionView;

- (CGSize)collectionView:(UICollectionView * _Nonnull)collectionView
                  layout:(UICollectionViewLayout * _Nonnull)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (UICollectionViewCell *_Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void)collectionView:(UICollectionView * _Nonnull)collectionView
       willDisplayCell:(UICollectionViewCell * _Nonnull)cell
    forItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

// Common Methods
- (void) registerNib:(UINib * _Nonnull )nib withCellWithReuseIdentifier:( NSString * _Nonnull )identifier forType:(SFItemType)type;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;


@end
