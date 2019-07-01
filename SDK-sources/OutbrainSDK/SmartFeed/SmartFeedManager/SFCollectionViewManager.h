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
#import "SFVideoCollectionViewCell.h"

@import WebKit;


@interface SFCollectionViewManager : NSObject

@property (nonatomic, weak) id<SFPrivateEventListener> _Nullable eventListenerTarget;
@property (nonatomic, weak) id<WKUIDelegate> _Nullable wkWebviewDelegate;
@property (nonatomic, weak, readonly) UICollectionView * _Nullable collectionView;
@property (nonatomic) BOOL displaySourceOnOrganicRec;


- (id _Nonnull )initWitCollectionView:(UICollectionView * _Nonnull)collectionView;

- (void) configureSmartfeedHeaderCell:(UICollectionViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath withTitle:(NSString * _Nullable)title isSmartfeedWithNoChildren:(BOOL)isSmartfeedWithNoChildren;

- (void) configureSingleCell:(UICollectionViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath withSFItem:(SFItemData * _Nonnull)sfItem;
- (void) configureVideoCell:(UICollectionViewCell * _Nonnull)cell atIndexPath:(NSIndexPath * _Nonnull)indexPath withSFItem:(SFItemData * _Nonnull)sfItem;

- (UICollectionViewCell * _Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView headerCellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath isRTL:(BOOL)isRTL;

- (UICollectionViewCell * _Nonnull)collectionView:(UICollectionView * _Nonnull)collectionView cellForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath sfItem:(SFItemData * _Nonnull)sfItem;

- (CGSize) collectionView:(UICollectionView * _Nonnull)collectionView
   sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
                   sfItem:(SFItemData * _Nonnull)sfItem;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

+ (void) configureVideoCell:(SFVideoCollectionViewCell * _Nonnull)videoCell
                 withSFItem:(SFItemData * _Nonnull)sfItem
               wkUIDelegate:(id <WKUIDelegate> _Nullable)wkUIDelegate
        eventListenerTarget:(id<SFPrivateEventListener> _Nullable) eventListenerTarget
         tapGestureDelegate:(id<UIGestureRecognizerDelegate> _Nullable)tapGestureDelegate;

@end
