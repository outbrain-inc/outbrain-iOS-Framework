//
//  OBSFCollectionViewManager.m
//  OutbrainSDK
//
//  Created by oded regev on 09/08/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFCollectionViewManager.h"
#import "SFHorizontalCollectionViewCell.h"
#import "SFUtils.h"
#import "SFImageLoader.h"

@interface SFCollectionViewManager() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@end


@implementation SFCollectionViewManager

const NSString *kCollectionViewHorizontalCarouselReuseId = @"SFHorizontalCarouselCollectionViewCell";
const NSString *kCollectionViewSingleWithThumbnailReuseId = @"SFSingleWithThumbnailCollectionCell";
const NSString *kCollectionViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleCollectionViewCell";
const NSString *kCollectionViewSingleWithTitleReuseId = @"SFSingleWithTitleCollectionViewCell";
const NSString *kCollectionViewSingleReuseId = @"SFCollectionViewCell";

- (id _Nonnull )initWitCollectionView:(UICollectionView * _Nonnull)collectionView
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        
        self.collectionView = collectionView;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        // horizontal cells
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCarouselCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalCarouselCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalCarouselReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedNoTitleCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedNoTitleCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalFixedNoTitleReuseId];
        
        // Single item cell
        UINib *collectionViewCellNib = [UINib nibWithNibName:@"SFCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"collectionViewCellNib should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleReuseId];
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleWithTitleCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleWithTitleCollectionViewCell should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleWithTitleReuseId];
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleWithThumbnailCollectionCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleWithThumbnailCollectionCell should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailReuseId];
        
    }
    return self;
}

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    if (self.collectionView != nil) {
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
}

-(void) reloadUIData:(NSUInteger) currentCount indexPaths:(NSArray *)indexPaths sectionIndex:(NSInteger)sectionIndex {
    if (self.collectionView != nil) {
        //[self.collectionView reloadData];
        [self.collectionView performBatchUpdates:^{
            if (currentCount == 0) {
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }
            [self.collectionView insertItemsAtIndexPaths:indexPaths];
        } completion:nil];
    }
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath sfItemType:(SFItemType)sfItemType
{
    switch (sfItemType) {
        case SingleItem:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleReuseId forIndexPath:indexPath];
        case CarouselItem:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalCarouselReuseId forIndexPath:indexPath];
        case GridTwoInRowNoTitle:
        case GridThreeInRowNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalFixedNoTitleReuseId forIndexPath:indexPath];
        case StripWithTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithTitleReuseId forIndexPath:indexPath];
        case StripWithThumbnail:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailReuseId forIndexPath:indexPath];
            
        default:
            break;
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView
   sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
               sfItemType:(SFItemType)sfItemType {
    
    CGFloat width = collectionView.frame.size.width;
    if (sfItemType == GridTwoInRowNoTitle || sfItemType == GridThreeInRowNoTitle) {
        return CGSizeMake(width, 250.0);
    }
    else if (sfItemType == StripWithTitle) {
        return CGSizeMake(width, 280.0);
    }
    else if (sfItemType == StripWithThumbnail) {
        return CGSizeMake(width - 20.0, 120.0);
    }
    
    return CGSizeMake(width - 20.0, 250.0);
}

- (void) configureSingleCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem {
    SFCollectionViewCell *singleCell = (SFCollectionViewCell *)cell;
    const NSInteger cellTag = indexPath.row;
    singleCell.tag = cellTag;
    singleCell.contentView.tag = cellTag;
    if (singleCell.cardContentView) {
        singleCell.cardContentView.tag = cellTag;
    }
    
    OBRecommendation *rec = sfItem.singleRec;
    singleCell.recTitleLabel.text = rec.content;
    NSAssert(self.clickListenerTarget != nil, @"self.clickListenerTarget must not be nil");
    
    if ([rec isPaidLink]) {
        singleCell.recSourceLabel.text = [NSString stringWithFormat:@"Sponsored | %@", rec.source];
        if ([rec shouldDisplayDisclosureIcon]) {
            singleCell.adChoicesButton.hidden = NO;
            singleCell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            singleCell.adChoicesButton.tag = cellTag;
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            UIImage *adChoicesImage = [UIImage imageNamed:@"adchoices-icon" inBundle:bundle compatibleWithTraitCollection:nil];
            [singleCell.adChoicesButton setImage:adChoicesImage forState:UIControlStateNormal];
            [singleCell.adChoicesButton addTarget:self.clickListenerTarget action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            singleCell.adChoicesButton.hidden = YES;
        }
    }
    else {
        singleCell.recSourceLabel.text = rec.source;
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:singleCell.recImageView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.clickListenerTarget  action:@selector(recommendationClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    
    // Cell Specific configuration
    if (sfItem.itemType == StripWithTitle) {
        [SFUtils addDropShadowToView: singleCell.cardContentView];
        if (sfItem.widgetTitle) {
            singleCell.cellTitleLabel.text = sfItem.widgetTitle;
        }
        else {
            // fallback
            singleCell.cellTitleLabel.text = @"Around the web";
        }
    
        singleCell.outbrainLabelingContainer.hidden = ![rec isPaidLink];
        singleCell.recTitleLabel.textColor = [rec isPaidLink] ? UIColorFromRGB(0x171717) : UIColorFromRGB(0x808080);
        [singleCell.outbrainLabelingContainer addTarget:self.clickListenerTarget action:@selector(outbrainLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [singleCell.cardContentView addGestureRecognizer:tapGesture];
    }
    else {
        [SFUtils addDropShadowToView: singleCell];
        [singleCell.contentView addGestureRecognizer:tapGesture];
    }
    
    if (sfItem.itemType == SingleItem) {
        singleCell.sponsoredLabel.hidden = ![rec isPaidLink];
    }
}

@end
