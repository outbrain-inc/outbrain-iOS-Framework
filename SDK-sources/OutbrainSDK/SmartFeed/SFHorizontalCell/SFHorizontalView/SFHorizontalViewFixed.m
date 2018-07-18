//
//  SFHorizontalViewFixed.m
//  OutbrainSDK
//
//  Created by oded regev on 16/07/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalViewFixed.h"

@implementation SFHorizontalViewFixed

const CGFloat kInsetMargin = 10.0;

// https://developer.apple.com/documentation/uikit/uicollectionviewflowlayout/1617717-minimumlinespacing?language=objc
const CGFloat kDefaultMinimumLineSpacing = 10.0;


-(void) setupView {
    [super setupView];
    
    const CGFloat itemWidth = (self.collectionView.frame.size.width - kInsetMargin*2 - kDefaultMinimumLineSpacing)*0.5;
    const CGFloat itemHeight = self.collectionView.frame.size.height;
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    self.collectionView.scrollEnabled = NO;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //return UIEdgeInsetsMake(top, left, bottom, right);
    return UIEdgeInsetsMake(0, kInsetMargin, 0, kInsetMargin);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemSize;
}

@end
