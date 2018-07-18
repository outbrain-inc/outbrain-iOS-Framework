//
//  SFHorizontalView.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

@interface SFHorizontalView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>

typedef void(^OnClick)(OBRecommendation *rec);

- (void) setupView;

- (void) registerNib:(UINib *_Nonnull)nib forCellWithReuseIdentifier:(NSString *_Nonnull)identifier;

@property (nonatomic, strong) NSArray * _Nullable outbrainRecs;
@property (nonatomic) OnClick _Nonnull onClick;


// This section was private, now its here for the children classes
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSString *horizontalCellIdentifier;
@property (nonatomic, strong) UINib *horizontalItemCellNib;

@property (nonatomic, assign) BOOL didInitCollectionViewLayout;
@property (nonatomic, assign) CGSize itemSize;


@end
