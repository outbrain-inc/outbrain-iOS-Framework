//
//  SFHorizontalViewCarousel.m
//  OutbrainSDK
//
//  Created by oded regev on 16/07/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalViewCarousel.h"
#import "PageCollectionLayout.h"
#import "BrandedCarouselCollectionLayout.h"
#import "SFUtils.h"

@implementation SFHorizontalViewCarousel

NSInteger const kBrandedCarouselTag = 111;

-(void) setupView {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    [super setupView];
    
    if (self.carouselItemSizeCallback) { // app developer override point
        self.itemSize = self.carouselItemSizeCallback();
    }
    else {
        const BOOL isBrandedCarousel = self.tag == kBrandedCarouselTag;
        if (isBrandedCarousel) {
            const CGFloat itemWidth = screenWidth*0.7;
            const CGFloat itemHeight = self.collectionView.frame.size.height*0.95;
            self.itemSize = CGSizeMake(itemWidth, itemHeight);
        }
        else {
            const CGFloat itemHeight = MAX(self.collectionView.frame.size.height*(0.95), 220.0);
            const CGFloat itemWidth = MAX(self.collectionView.frame.size.width*(0.83), itemHeight); ;
            self.itemSize = CGSizeMake(itemWidth, itemHeight);
        }
    }
    
    [self resetLayout:self.itemSize];
}

-(void) resetLayout:(CGSize) itemSize {
    const BOOL isBrandedCarousel = self.tag == kBrandedCarouselTag;
    self.itemSize = itemSize;
    UICollectionViewFlowLayout *layout = nil;
    
    if (isBrandedCarousel) {
        layout = [[BrandedCarouselCollectionLayout alloc] initWithItemSize:self.itemSize];
    }
    else {
        layout = [[PageCollectionLayout alloc] initWithItemSize:self.itemSize];
    }

    self.collectionView.collectionViewLayout = layout;
    [self.collectionView.collectionViewLayout invalidateLayout];
    // NSLog(@"resetLayout - self.itemSize: width: %f, height: %f", self.itemSize.width, self.itemSize.height);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if ([[SFUtils sharedInstance] darkMode]) {
        SFCollectionViewCell *sfCell = (SFCollectionViewCell *)cell;
        sfCell.recTitleLabel.textColor = [[SFUtils sharedInstance] titleColor];
    }
    return cell;
}

@end
