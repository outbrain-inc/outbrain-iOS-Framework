//
//  BrandedCarouselCollectionLayout.m
//  OutbrainSDK
//
//  Created by oded regev on 18/06/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "BrandedCarouselCollectionLayout.h"

@implementation BrandedCarouselCollectionLayout

// Branded Carousel
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGSize collectionViewSize = self.collectionView.bounds.size;
    CGFloat width = collectionViewSize.width;
    CGFloat halfWidth = width * 0.5;

    CGFloat direction = (proposedContentOffset.x > self.collectionView.contentOffset.x ? 1 : 0);
    CGFloat pageOffsetX = self.itemSize.width * floor(self.collectionView.contentOffset.x / self.itemSize.width);
    CGFloat proposedContentOffsetCenterX = pageOffsetX + (width * direction);
    CGRect proposedRect = CGRectMake(proposedContentOffsetCenterX, 0, collectionViewSize.width, collectionViewSize.height);

    UICollectionViewLayoutAttributes *candidateAttributes;

    for (UICollectionViewLayoutAttributes *attributes in [self layoutAttributesForElementsInRect:proposedRect]) {
        if (attributes.representedElementCategory != UICollectionElementCategoryCell) continue;

        candidateAttributes = attributes;
        if (direction == 1) {
            break; // if direction right, take the first item (break), else take the last
        }
    }
    
    if (direction == 1)
        proposedContentOffset.x = candidateAttributes.center.x - halfWidth;
    else {
        proposedContentOffset.x = candidateAttributes.center.x - halfWidth - self.itemSize.width;
    }

    return proposedContentOffset;
}

@end
