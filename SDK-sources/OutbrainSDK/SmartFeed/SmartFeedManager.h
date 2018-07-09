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

@end


@interface SmartFeedManager : NSObject

@property (nonatomic, strong, readonly) NSString * _Nullable url;
@property (nonatomic, strong, readonly) NSString * _Nullable widgetId;
@property (nonatomic, assign) NSInteger appNumberOfSections;


// TableView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
                  tableView:(UITableView * _Nonnull)tableView
              publisherName:(NSString * _Nonnull)publisherName
             publisherImage:(UIImage * _Nonnull)publisherImage;

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;

// CollectionView
- (id _Nonnull )initWithUrl:(NSString * _Nonnull)url
                   widgetID:(NSString * _Nonnull)widgetId
             collectionView:(UICollectionView * _Nonnull)collectionView
              publisherName:(NSString * _Nonnull)publisherName
             publisherImage:(UIImage * _Nonnull)publisherImage;

- (UICollectionViewCell *_Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void)collectionView:(UICollectionView * _Nonnull)collectionView
       willDisplayCell:(UICollectionViewCell * _Nonnull)cell
    forItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath;

- (void) registerHorizontalItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

@property (nonatomic, weak) id<SmartFeedDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableArray *smartFeedItemsArray;

@end
