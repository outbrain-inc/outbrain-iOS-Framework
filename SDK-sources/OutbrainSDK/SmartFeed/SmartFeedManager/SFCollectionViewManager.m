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
#import "SFCollectionViewHeaderCell.h"
#import "SFVideoCollectionViewCell.h"
#import "OBDisclosure.h"

@interface SFCollectionViewManager() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@end


@implementation SFCollectionViewManager

NSString * const kCollectionViewHorizontalCarouselWithTitleReuseId = @"SFHorizontalCarouselWithTitleCollectionViewCell";
NSString * const kCollectionViewHorizontalCarouselNoTitleReuseId = @"SFHorizontalCarouselNoTitleCollectionViewCell";
NSString * const kCollectionViewSmartfeedHeaderReuseId = @"SFCollectionViewHeaderCell";
NSString * const kCollectionViewSmartfeedRTLHeaderReuseId = @"SFCollectionViewRTLHeaderCell";
NSString * const kCollectionViewSingleWithThumbnailReuseId = @"SFSingleWithThumbnailCollectionCell";
NSString * const kCollectionViewSingleWithThumbnailWithTitleReuseId = @"SFSingleWithThumbnailWithTitleCollectionCell";
NSString * const kCollectionViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleCollectionViewCell";
NSString * const kCollectionViewHorizontalFixedWithTitleReuseId = @"SFHorizontalFixedWithTitleCollectionViewCell";
NSString * const kCollectionViewSingleWithTitleReuseId = @"SFSingleWithTitleCollectionViewCell";
NSString * const kCollectionViewSingleReuseId = @"SFCollectionViewCell";
NSString * const kCollectionViewSingleVideoReuseId = @"kCollectionViewSingleVideoReuseId";
NSString * const SFSingleVideoWithTitleCollectionViewReuseId = @"SFSingleVideoWithTitleCollectionViewCell";
NSString * const SFSingleVideoNoTitleCollectionViewReuseId = @"SFSingleVideoNoTitleCollectionViewCell";
NSString * const SFHorizontalFixedWithVideoCellReuseId = @"SFHorizontalFixedWithVideoCollectionViewCell";
NSString * const SFHorizontalFixedWithTitleWithVideoCellReuseId = @"SFHorizontalFixedWithTitleWithVideoCollectionViewCell";

- (id _Nonnull )initWitCollectionView:(UICollectionView * _Nonnull)collectionView
{
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        
        self.collectionView = collectionView;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        // Smartfeed header cell
        UINib *headerCellNib = [UINib nibWithNibName:@"SFCollectionViewHeaderCell" bundle:bundle];
        NSAssert(headerCellNib != nil, @"SFCollectionViewHeaderCell should not be null");
        [collectionView registerNib:headerCellNib forCellWithReuseIdentifier: kCollectionViewSmartfeedHeaderReuseId];
        
        headerCellNib = [UINib nibWithNibName:@"SFCollectionViewRTLHeaderCell" bundle:bundle];
        NSAssert(headerCellNib != nil, @"SFCollectionViewRTLHeaderCell should not be null");
        [collectionView registerNib:headerCellNib forCellWithReuseIdentifier: kCollectionViewSmartfeedRTLHeaderReuseId];
        
        // video cell
        [collectionView registerClass:[SFVideoCollectionViewCell class] forCellWithReuseIdentifier:kCollectionViewSingleVideoReuseId];
        
        // horizontal cells
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCarouselWithTitleCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalCarouselWithTitleCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalCarouselWithTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCarouselNoTitleCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalCarouselNoTitleCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalCarouselNoTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedNoTitleCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedNoTitleCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalFixedNoTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedWithTitleCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedWithTitleCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: kCollectionViewHorizontalFixedWithTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedWithVideoCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedWithVideoCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: SFHorizontalFixedWithVideoCellReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedWithTitleWithVideoCollectionViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedWithTitleWithVideoCollectionViewCell should not be null");
        [collectionView registerNib:horizontalCellNib forCellWithReuseIdentifier: SFHorizontalFixedWithTitleWithVideoCellReuseId];
        
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
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleWithThumbnailWithTitleCollectionCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleWithThumbnailWithTitleCollectionCell should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailWithTitleReuseId];
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleVideoWithTitleCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleVideoWithTitleCollectionViewCell should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: SFSingleVideoWithTitleCollectionViewReuseId];
        
        collectionViewCellNib = [UINib nibWithNibName:@"SFSingleVideoNoTitleCollectionViewCell" bundle:bundle];
        NSAssert(collectionViewCellNib != nil, @"SFSingleVideoNoTitleCollectionViewReuseId should not be null");
        [self registerSingleItemNib: collectionViewCellNib forCellWithReuseIdentifier: SFSingleVideoNoTitleCollectionViewReuseId];
        
    }
    return self;
}

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    if (self.collectionView != nil) {
        [self.collectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    }
}

#pragma mark - Collection View methods
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView headerCellForItemAtIndexPath:(NSIndexPath *)indexPath isRTL:(BOOL)isRTL {
    NSString * const reuseId = isRTL ? kCollectionViewSmartfeedRTLHeaderReuseId : kCollectionViewSmartfeedHeaderReuseId;
    return [collectionView dequeueReusableCellWithReuseIdentifier: reuseId forIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath sfItem:(SFItemData *)sfItem {
    switch (sfItem.itemType) {
        case SFTypeStripNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleReuseId forIndexPath:indexPath];
        case SFTypeCarouselWithTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalCarouselWithTitleReuseId forIndexPath:indexPath];
        case SFTypeCarouselNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalCarouselNoTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowNoTitle:
        case SFTypeGridThreeInRowNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalFixedNoTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithTitle:
        case SFTypeGridThreeInRowWithTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewHorizontalFixedWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripWithTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripWithThumbnailNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailReuseId forIndexPath:indexPath];
        case SFTypeStripWithThumbnailWithTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleWithThumbnailWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripVideo:
            return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSingleVideoReuseId forIndexPath:indexPath];
        case SFTypeStripVideoWithPaidRecAndTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: SFSingleVideoWithTitleCollectionViewReuseId forIndexPath:indexPath];
        case SFTypeStripVideoWithPaidRecNoTitle:
            return [collectionView dequeueReusableCellWithReuseIdentifier: SFSingleVideoNoTitleCollectionViewReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithVideo:
            return [collectionView dequeueReusableCellWithReuseIdentifier: SFHorizontalFixedWithVideoCellReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithTitleWithVideo:
            return [collectionView dequeueReusableCellWithReuseIdentifier: SFHorizontalFixedWithTitleWithVideoCellReuseId forIndexPath:indexPath];
        default:
            return nil;
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView
   sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
               sfItem:(SFItemData *)sfItem {
    
    // ipad 834
    // phone 375
    SFItemType sfItemType = sfItem.itemType;
    
    CGFloat screenWidth = collectionView.frame.size.width;
    if (sfItemType == SFTypeGridTwoInRowNoTitle ||
        sfItemType == SFTypeCarouselWithTitle ||
        sfItemType == SFTypeCarouselNoTitle ||
        sfItemType == SFTypeGridTwoInRowWithVideo) {
        return CGSizeMake(screenWidth, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 380.0 : 240.0);
    }
    else if (sfItemType == SFTypeGridThreeInRowNoTitle) {
        return CGSizeMake(screenWidth, 280.0);
    }
    else if (sfItemType == SFTypeGridTwoInRowWithTitle ||
             sfItemType == SFTypeGridTwoInRowWithTitleWithVideo) {
        return CGSizeMake(screenWidth, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 440.0 : 270.0);
    }
    else if ((sfItemType == SFTypeStripWithTitle) || (sfItemType == SFTypeStripVideoWithPaidRecAndTitle)) {
        return CGSizeMake(screenWidth, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2*(screenWidth/3) : 280.0);
    }
    else if (sfItemType == SFTypeStripWithThumbnailNoTitle) {
        return CGSizeMake(screenWidth - 20.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 180.0 : 120.0);
    }
    else if (sfItemType == SFTypeStripWithThumbnailWithTitle) {
        return CGSizeMake(screenWidth, 150.0);
    }
    else if (sfItemType == SFTypeStripVideo) {
        return CGSizeMake(screenWidth - 20.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 350.0 : 250.0);
    }
    
    return CGSizeMake(screenWidth - 20.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 1.8*(screenWidth/3) : 250.0);
}

- (void) configureSmartfeedHeaderCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withTitle:(NSString *)title isSmartfeedWithNoChildren:(BOOL)isSmartfeedWithNoChildren {
    SFCollectionViewHeaderCell *sfHeaderCell = (SFCollectionViewHeaderCell *)cell;
    if (title) {
        sfHeaderCell.headerLabel.text = title;
    }
    
    if (isSmartfeedWithNoChildren) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        sfHeaderCell.headerImageView.image = [UIImage imageNamed:@"outbrain-logo" inBundle:bundle compatibleWithTraitCollection:nil];
        [sfHeaderCell.adChoicesImageView removeFromSuperview];
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.eventListenerTarget  action:@selector(outbrainLabelClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [sfHeaderCell.contentView addGestureRecognizer:tapGesture];
}

- (void) configureVideoCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem
{
    SFVideoCollectionViewCell *videoCell = (SFVideoCollectionViewCell *)cell;
    [self configureSingleCell:cell atIndexPath:indexPath withSFItem:sfItem];
    
    if ([self.eventListenerTarget respondsToSelector:@selector(isVideoCurrentlyPlaying)] &&
        self.eventListenerTarget.isVideoCurrentlyPlaying) {
        return;
    }
    
    [SFCollectionViewManager configureVideoInCell:videoCell withSFItem:sfItem wkUIDelegate:self.wkWebviewDelegate];
}

- (void) configureSingleCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem {
    SFCollectionViewCell *singleCell = (SFCollectionViewCell *)cell;
    const NSInteger cellTag = indexPath.row;
    singleCell.tag = cellTag;
    singleCell.contentView.tag = cellTag;
    if (singleCell.cardContentView) {
        singleCell.cardContentView.tag = cellTag;
    }
    
    [SFCollectionViewManager configureSingleCell:cell withSFItem:sfItem eventListenerTarget:self.eventListenerTarget cellTag:cellTag tapGestureDelegate:self displaySourceOnOrganicRec:self.displaySourceOnOrganicRec disableCellShadows:self.disableCellShadows];
}

+ (void) configureSingleCell:(UICollectionViewCell *)cell
                  withSFItem:(SFItemData *)sfItem
         eventListenerTarget:(id<SFPrivateEventListener>)eventListenerTarget
                     cellTag:(NSInteger)cellTag
          tapGestureDelegate:(id<UIGestureRecognizerDelegate>)tapGestureDelegate
{
    
    [self configureSingleCell:cell
                   withSFItem:sfItem
          eventListenerTarget:eventListenerTarget
                      cellTag:cellTag
           tapGestureDelegate:tapGestureDelegate
    displaySourceOnOrganicRec:NO
     disableCellShadows:NO];
}

+ (void) configureSingleCell:(UICollectionViewCell *)cell
                  withSFItem:(SFItemData *)sfItem
         eventListenerTarget:(id<SFPrivateEventListener>)eventListenerTarget
                     cellTag:(NSInteger)cellTag
          tapGestureDelegate:(id<UIGestureRecognizerDelegate>)tapGestureDelegate
   displaySourceOnOrganicRec:(BOOL)displaySourceOnOrganicRec
          disableCellShadows:(BOOL)disableCellShadows
{
    SFCollectionViewCell *singleCell = (SFCollectionViewCell *)cell;
    
    OBRecommendation *rec = sfItem.singleRec;
    
    // If rec title is RTL we will set the source text alignment to be the same, otherwise it will look weird in the UI.
    NSTextAlignment textAlignment = [SFUtils isRTL:rec.content] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    singleCell.recTitleLabel.textAlignment = textAlignment;
    singleCell.recSourceLabel.textAlignment = textAlignment;
    
    if ([SFUtils isRTL:rec.content]) {
        [singleCell.contentView setNeedsDisplay];
        [singleCell.contentView setNeedsLayout];
    }
    
    singleCell.recTitleLabel.text = rec.content;
    singleCell.recSourceLabel.text = [SFUtils getRecSourceText:rec.source withSourceFormat:sfItem.odbSettings.sourceFormat];
    
    NSAssert(eventListenerTarget != nil, @"clickListenerTarget must not be nil");
    
    [SFUtils removePaidLabelFromImageView:singleCell.recImageView];
    
    if ([rec isPaidLink]) {
        if ([rec shouldDisplayDisclosureIcon]) {
            singleCell.adChoicesButton.hidden = NO;
            singleCell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            singleCell.adChoicesButton.tag = cellTag;
            [[SFImageLoader sharedInstance] loadImage:rec.disclosure.imageUrl intoButton:singleCell.adChoicesButton];
            [singleCell.adChoicesButton addTarget:eventListenerTarget action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            singleCell.adChoicesButton.hidden = YES;
        }
        
        // Paid label
        [SFUtils configurePaidLabelToImageViewIfneeded:singleCell.recImageView withSettings:sfItem.odbSettings];
    }
    else {
        if (rec.publisherLogoImage) {
            [[SFImageLoader sharedInstance] loadImage:rec.publisherLogoImage.url into:singleCell.publisherLogo];
            singleCell.publisherLogoWidth.constant = rec.publisherLogoImage.width;
            singleCell.publisherLogoHeight.constant = rec.publisherLogoImage.height;
            if (!sfItem.isCustomUI && !displaySourceOnOrganicRec) {
                singleCell.recSourceLabel.text = @"";
            }
        }
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:singleCell.recImageView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:eventListenerTarget  action:@selector(recommendationClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:tapGestureDelegate];
    
    // Cell Specific configuration
    if (sfItem.itemType == SFTypeStripWithTitle ||
        sfItem.itemType == SFTypeStripWithThumbnailWithTitle ||
        sfItem.itemType == SFTypeStripVideoWithPaidRecAndTitle)
    {
        if (!disableCellShadows) {
            if ([rec isPaidLink] && (sfItem.shadowColor != nil)) {
                [SFUtils addDropShadowToView: singleCell.cardContentView shadowColor:sfItem.shadowColor];
            }
            else {
                [SFUtils addDropShadowToView: singleCell.cardContentView];
            }
        }
        
        if (sfItem.widgetTitle) {
            singleCell.cellTitleLabel.text = sfItem.widgetTitle;
        }
        else {
            // fallback
            singleCell.cellTitleLabel.text = @"Around the web";
        }
        
        singleCell.outbrainLabelingContainer.hidden = ![rec isPaidLink];
        if (!sfItem.isCustomUI) {
            singleCell.recTitleLabel.textColor = [rec isPaidLink] ? UIColorFromRGB(0x171717) : UIColorFromRGB(0x808080);
        }
        
        [singleCell.outbrainLabelingContainer addTarget:eventListenerTarget action:@selector(outbrainLabelClicked:) forControlEvents:UIControlEventTouchUpInside];
        [singleCell.cardContentView addGestureRecognizer:tapGesture];
    }
    else {
        if (!disableCellShadows) {
            if ([rec isPaidLink] && (sfItem.shadowColor != nil)) {
                [SFUtils addDropShadowToView: singleCell shadowColor:sfItem.shadowColor];
            }
            else {
                [SFUtils addDropShadowToView: singleCell];
            }
        }
        
        [singleCell.contentView addGestureRecognizer:tapGesture];
    }
}

+ (void) configureVideoCell:(SFVideoCollectionViewCell *)videoCell
                 withSFItem:(SFItemData *)sfItem
               wkUIDelegate:(id <WKUIDelegate>)wkUIDelegate
        eventListenerTarget:(id<SFPrivateEventListener>) eventListenerTarget
         tapGestureDelegate:(id<UIGestureRecognizerDelegate>)tapGestureDelegate
{
    
    [SFCollectionViewManager configureSingleCell:videoCell withSFItem:sfItem eventListenerTarget:eventListenerTarget cellTag:0 tapGestureDelegate:tapGestureDelegate];
    
    [SFCollectionViewManager configureVideoInCell:videoCell withSFItem:sfItem wkUIDelegate:wkUIDelegate];
}

+(void) configureVideoInCell:(SFVideoCollectionViewCell *)videoCell withSFItem:(SFItemData *)sfItem wkUIDelegate:(id <WKUIDelegate>)wkUIDelegate {
    BOOL shouldReturn = [SFUtils configureGenericVideoCell:videoCell sfItem:sfItem];
    if (shouldReturn) {
        return;
    }
    
    videoCell.webview = [SFUtils createVideoWebViewInsideView:videoCell.cardContentView withSFItem:sfItem scriptMessageHandler:videoCell.wkScriptMessageHandler uiDelegate:wkUIDelegate withHorizontalMargin:NO];
    
    [SFUtils loadVideoURLIn:videoCell sfItem:sfItem];
}

@end
