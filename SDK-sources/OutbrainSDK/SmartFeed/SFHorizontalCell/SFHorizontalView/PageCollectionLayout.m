//
//  PageCollectionLayout.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "PageCollectionLayout.h"

@interface PageCollectionLayout()

//@property (nonatomic, assign)


@end


@implementation PageCollectionLayout

CGSize lastCollectionViewSize;
CGFloat scalingOffset = 200.0;
CGFloat minimumScaleFactor = 0.9;
CGFloat minimumAlphaFactor = 0.3;
BOOL scaleItems = YES;

- (instancetype)init
{
    return [self initWithItemSize:CGSizeZero];
}

- (id)initWithItemSize:(CGSize)itemSize
{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumLineSpacing = 5.0;
        self.itemSize = itemSize;
        lastCollectionViewSize = CGSizeZero;
    }
    return self;
}

- (void)invalidateLayoutWithContext:(UICollectionViewLayoutInvalidationContext *)context {
    [super invalidateLayoutWithContext:context];
    
    if (! CGSizeEqualToSize(self.collectionView.bounds.size, lastCollectionViewSize)) {
        [self configureInset];
        lastCollectionViewSize = self.collectionView.bounds.size;
    }
}

-(void) configureInset {
    CGFloat inset = self.collectionView.bounds.size.width / 2 - self.itemSize.width / 2;
    self.collectionView.contentInset = UIEdgeInsetsMake(0, inset, 0, inset);
    self.collectionView.contentOffset = CGPointMake(-inset, 0);
}

-(BOOL) shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *superAttributes = [super layoutAttributesForElementsInRect:rect];
    
    if (scaleItems == NO) {
        return superAttributes;
    }
    
    CGPoint contentOffset = self.collectionView.contentOffset;
    CGSize size = self.collectionView.bounds.size;
    CGRect visibleRect = CGRectMake(contentOffset.x, contentOffset.y, size.width, size.height);
    CGFloat visibleCenterX = CGRectGetMidX(visibleRect);
    
    NSArray *newAttributesArray = [[NSArray alloc] initWithArray:superAttributes copyItems:YES];
    
    for (UICollectionViewLayoutAttributes *attr in newAttributesArray) {
        CGFloat distanceFromCenter = visibleCenterX - attr.center.x;
        CGFloat absDistanceFromCenter = MIN(ABS(distanceFromCenter), scalingOffset);
        CGFloat scale = absDistanceFromCenter * (minimumScaleFactor - 1) / scalingOffset + 1;
        attr.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1);
        CGFloat alpha = absDistanceFromCenter * (minimumAlphaFactor - 1) / scalingOffset + 1;
        attr.alpha = alpha;
    }
    
    return newAttributesArray;
}

-(CGPoint) targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    CGRect proposedRect = CGRectMake(proposedContentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray *layoutAttributes = [self layoutAttributesForElementsInRect:proposedRect];
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + self.collectionView.bounds.size.width / 2;
    UICollectionViewLayoutAttributes *candidateAttributes = nil;

    for (UICollectionViewLayoutAttributes *attributes in layoutAttributes) {
        if ([attributes representedElementCategory] != UICollectionElementCategoryCell) {
            continue;
        }

        if (candidateAttributes == nil) {
            candidateAttributes = attributes;
            continue;
        }

        if (fabs(attributes.center.x - proposedContentOffsetCenterX) < fabs(candidateAttributes.center.x - proposedContentOffsetCenterX)) {
            candidateAttributes = attributes;
        }
    }

    if (candidateAttributes == nil) {
        return proposedContentOffset;
    }

    CGFloat newOffsetX = candidateAttributes.center.x - self.collectionView.bounds.size.width / 2;
    CGFloat offset = newOffsetX - self.collectionView.contentOffset.x;
    if ((velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0)) {
        CGFloat pageWidth = self.itemSize.width + self.minimumLineSpacing;
        newOffsetX += velocity.x > 0 ? pageWidth : -pageWidth;
    }

    return CGPointMake(newOffsetX, proposedContentOffset.y);
}



@end

