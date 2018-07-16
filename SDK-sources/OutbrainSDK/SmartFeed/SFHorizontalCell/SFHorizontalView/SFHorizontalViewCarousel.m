//
//  SFHorizontalViewCarousel.m
//  OutbrainSDK
//
//  Created by oded regev on 16/07/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalViewCarousel.h"
#import "PageCollectionLayout.h"

@implementation SFHorizontalViewCarousel

-(void) setupView {
    [super setupView];
    
    const CGFloat itemWidth = MAX(self.collectionView.frame.size.width*0.6, 250.0);
    const CGFloat itemHeight = MIN(itemWidth*0.7, self.collectionView.frame.size.height);
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    [self resetLayout:self.itemSize];
}

-(void) resetLayout:(CGSize) itemSize {
    self.itemSize = itemSize;
    UICollectionViewFlowLayout *layout = [[PageCollectionLayout alloc] initWithItemSize:self.itemSize];
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView.collectionViewLayout invalidateLayout];
    // NSLog(@"resetLayout - self.itemSize: width: %f, height: %f", self.itemSize.width, self.itemSize.height);
}


@end
