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


@interface SFCollectionViewManager : NSObject

@property (nonatomic, weak) id<SFClickListener> clickListenerTarget;

- (id _Nonnull )initWitCollectionView:(UICollectionView * _Nonnull)collectionView;

-(void) reloadUIData:(NSUInteger) currentCount indexPaths:(NSArray *)indexPaths sectionIndex:(NSInteger)sectionIndex;

- (void) configureSingleCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem;

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath sfItemType:(SFItemType)sfItemType;

- (CGSize) collectionView:(UICollectionView *)collectionView
   sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
               sfItemType:(SFItemType)sfItemType;

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier;

@end
