//
//  SFCollectionViewManager.h
//  OutbrainSDK
//
//  Created by oded regev on 09/08/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SmartFeedManager.h"
#import "SFItemData.h"
#import "SFUtils.h"

@import WebKit;


@interface SFCollectionViewManager : NSObject

@property (nonatomic, weak) id<SFClickListener> clickListenerTarget;
@property (nonatomic, weak) id<WKUIDelegate> wkWebviewDelegate;
@property (nonatomic, weak, readonly) UICollectionView *collectionView;

- (id _Nonnull )initWitCollectionView:(UICollectionView * _Nonnull)collectionView;

- (void) configureSmartfeedHeaderCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withTitle:(NSString *)title isSmartfeedWithNoChildren:(BOOL)isSmartfeedWithNoChildren;

- (void) configureSingleCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem;
- (void) configureVideoCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView headerCellForItemAtIndexPath:(NSIndexPath *)indexPath isRTL:(BOOL)isRTL;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath sfItem:(SFItemData *)sfItem isRTL:(BOOL)isRTL;

- (CGSize) collectionView:(UICollectionView *)collectionView
   sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
                   sfItem:(SFItemData *)sfItem;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

@end
