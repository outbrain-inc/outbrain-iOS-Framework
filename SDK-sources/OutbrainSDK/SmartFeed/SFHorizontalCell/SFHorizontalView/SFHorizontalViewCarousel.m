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
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    [super setupView];
    
    if (self.carouselItemSizeCallback) { // app developer override point
        self.itemSize = self.carouselItemSizeCallback();
    }
    else {
        const BOOL isTablet = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
        const CGFloat itemWidth = screenWidth*0.7;
        const CGFloat itemHeight = self.collectionView.frame.size.height*0.95;
        
        self.itemSize = CGSizeMake(itemWidth, itemHeight);
    }
    
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
