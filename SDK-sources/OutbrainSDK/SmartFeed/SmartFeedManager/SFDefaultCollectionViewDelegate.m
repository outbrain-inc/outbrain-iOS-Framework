//
//  SFDefaultCollectionViewDelegate.m
//  OutbrainSDK
//
//  Created by oded regev on 29/07/2019.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import "SFDefaultCollectionViewDelegate.h"

@interface SFDefaultCollectionViewDelegate()

@property (nonatomic, weak) SmartFeedManager * _Nullable smartfeedManager;

@end 

@implementation SFDefaultCollectionViewDelegate

- (id _Nonnull )initWithSmartfeedManager:(SmartFeedManager * _Nonnull)smartfeedManager
{
    self = [super init];
    if (self) {
        NSLog(@"_init: %@", self);
        
        self.smartfeedManager = smartfeedManager;
    }
    return self;
}

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.smartfeedManager smartFeedItemsCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.smartfeedManager collectionView:collectionView cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.smartfeedManager collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
}

// UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.smartfeedManager collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

@end
