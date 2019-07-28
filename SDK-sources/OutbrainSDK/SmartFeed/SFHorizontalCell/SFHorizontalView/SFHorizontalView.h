//
//  SFHorizontalView.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecommendation.h"
#import "SFCollectionViewCell.h"
#import "SFItemData.h"

@interface SFHorizontalView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

typedef void(^OnRecommendationClick)(OBRecommendation * _Nullable rec);
typedef void(^OnAdChoicesIconClick)(NSURL * _Nullable url);
typedef CGSize(^CarouselItemSizeCallback)(void);
typedef void(^ConfigureHorizontalItem)(SFCollectionViewCell * _Nonnull cell, OBRecommendation * _Nonnull rec);

- (void) setupView;

- (void) registerNib:(UINib *_Nonnull)nib forCellWithReuseIdentifier:(NSString *_Nonnull)identifier;

@property (nonatomic, strong) SFItemData * _Nullable sfItem;
@property (nonatomic, strong) UIColor * _Nullable shadowColor;
@property (nonatomic) OnRecommendationClick _Nonnull onRecommendationClick;
@property (nonatomic) OnAdChoicesIconClick _Nonnull onAdChoicesIconClick;
@property (nonatomic) CarouselItemSizeCallback _Nullable carouselItemSizeCallback;
@property (nonatomic) ConfigureHorizontalItem _Nullable configureHorizontalItem;

// This section was private, now its here for the children classes
@property (nonatomic, strong) UICollectionView * _Nullable collectionView;
@property (nonatomic, copy) NSString * _Nullable horizontalCellIdentifier;
@property (nonatomic, strong) UINib * _Nullable horizontalItemCellNib;

@property (nonatomic, assign) BOOL didInitCollectionViewLayout;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic) BOOL displaySourceOnOrganicRec;

@end
