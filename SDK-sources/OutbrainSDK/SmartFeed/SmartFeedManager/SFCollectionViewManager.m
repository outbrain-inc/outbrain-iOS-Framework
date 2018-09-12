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

@interface SFCollectionViewManager() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

@end


@implementation SFCollectionViewManager

const NSString *kCollectionViewHorizontalCarouselWithTitleReuseId = @"SFHorizontalCarouselWithTitleCollectionViewCell";
const NSString *kCollectionViewHorizontalCarouselNoTitleReuseId = @"SFHorizontalCarouselNoTitleCollectionViewCell";
const NSString *kCollectionViewSmartfeedHeaderReuseId = @"SFCollectionViewHeaderCell";
const NSString *kCollectionViewSingleWithThumbnailReuseId = @"SFSingleWithThumbnailCollectionCell";
const NSString *kCollectionViewSingleWithThumbnailWithTitleReuseId = @"SFSingleWithThumbnailWithTitleCollectionCell";
const NSString *kCollectionViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleCollectionViewCell";
const NSString *kCollectionViewHorizontalFixedWithTitleReuseId = @"SFHorizontalFixedWithTitleCollectionViewCell";
const NSString *kCollectionViewSingleWithTitleReuseId = @"SFSingleWithTitleCollectionViewCell";
const NSString *kCollectionViewSingleReuseId = @"SFCollectionViewCell";
const NSString *kCollectionViewSingleVideoReuseId = @"kCollectionViewSingleVideoReuseId";

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
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView headerCellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [collectionView dequeueReusableCellWithReuseIdentifier: kCollectionViewSmartfeedHeaderReuseId forIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath sfItem:(SFItemData *)sfItem
{
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
        default:
            break;
    }
}

- (CGSize) collectionView:(UICollectionView *)collectionView
   sizeForItemAtIndexPath:(NSIndexPath * _Nonnull)indexPath
               sfItemType:(SFItemType)sfItemType {
    
    // ipad 834
    // phone 375
    CGFloat width = collectionView.frame.size.width;
    if (sfItemType == SFTypeGridTwoInRowNoTitle || sfItemType == SFTypeCarouselWithTitle || sfItemType == SFTypeCarouselNoTitle) {
        return CGSizeMake(width, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 380.0 : 240.0);
    }
    else if (sfItemType == SFTypeGridThreeInRowNoTitle) {
        return CGSizeMake(width, 280.0);
    }
    else if (sfItemType == SFTypeGridTwoInRowWithTitle) {
        return CGSizeMake(width, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 440.0 : 270.0);
    }
    else if (sfItemType == SFTypeStripWithTitle) {
        return CGSizeMake(width, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 380.0 : 280.0);
    }
    else if (sfItemType == SFTypeStripWithThumbnailNoTitle) {
        return CGSizeMake(width - 20.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 180.0 : 120.0);
    }
    else if (sfItemType == SFTypeStripWithThumbnailWithTitle) {
        return CGSizeMake(width, 150.0);
    }
    
    return CGSizeMake(width - 20.0, UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 350.0 : 250.0);
}

- (void) configureSmartfeedHeaderCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withTitle:(NSString *)title {
    SFCollectionViewHeaderCell *sfHeaderCell = (SFCollectionViewHeaderCell *)cell;
    if (title) {
        sfHeaderCell.headerOBLabel.text = title;
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.clickListenerTarget  action:@selector(outbrainLabelClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [sfHeaderCell.contentView addGestureRecognizer:tapGesture];
}

- (void) configureVideoCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem {
    SFVideoCollectionViewCell *videoCell = (SFVideoCollectionViewCell *)cell;
    const NSInteger cellTag = indexPath.row;
    videoCell.tag = cellTag;
    videoCell.contentView.backgroundColor = [UIColor blueColor];
    
    if (videoCell.webview) {
        [videoCell.webview removeFromSuperview];
        videoCell.webview = nil;
    }
    
    WKPreferences *preferences = [[WKPreferences alloc] init];
    preferences.javaScriptEnabled = YES;
    WKWebViewConfiguration *webviewConf = [[WKWebViewConfiguration alloc] init];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addScriptMessageHandler:self.wkScriptMsgHandler name:@"sdkObserver"];
    webviewConf.userContentController = controller;
    webviewConf.preferences = preferences;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:videoCell.contentView.frame configuration:webviewConf];
    webView.UIDelegate = self.wkWebviewDelegate;
    [videoCell.contentView addSubview:webView];
    videoCell.webview = webView;
    [SFUtils addConstraintsToFillParent:videoCell.webview];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:sfItem.videoUrl];
    [webView loadRequest:request];
    [videoCell.contentView setNeedsLayout];
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
        singleCell.recSourceLabel.text = rec.source;
        if ([rec shouldDisplayDisclosureIcon]) {
            singleCell.adChoicesButton.hidden = NO;
            singleCell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            singleCell.adChoicesButton.tag = cellTag;
            [[SFImageLoader sharedInstance] loadImage:rec.disclosure.imageUrl intoButton:singleCell.adChoicesButton];
            [singleCell.adChoicesButton addTarget:self.clickListenerTarget action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            singleCell.adChoicesButton.hidden = YES;
        }
    }
    else {
        singleCell.recSourceLabel.text = @"";
        if (rec.publisherLogoImage) {
            [[SFImageLoader sharedInstance] loadImage:rec.publisherLogoImage.url into:singleCell.publisherLogo];
        }
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:singleCell.recImageView];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.clickListenerTarget  action:@selector(recommendationClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    
    // Cell Specific configuration
    if (sfItem.itemType == SFTypeStripWithTitle || sfItem.itemType == SFTypeStripWithThumbnailWithTitle) {
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
}

@end
