//
//  SFTableViewManager.m
//  OutbrainSDK
//
//  Created by oded regev on 09/08/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFTableViewManager.h"
#import "SFItemData.h"
#import "SFHorizontalTableViewCell.h"
#import "SFUtils.h"
#import "SFImageLoader.h"
#import "SFVideoTableViewCell.h"
#import "OBDisclosure.h"

@interface SFTableViewManager() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation SFTableViewManager

const CGFloat kTableViewRowHeight = 250.0;
NSString * const kTableViewSingleReuseId = @"SFTableViewCell";
NSString * const kTableViewSmartfeedHeaderReuseId = @"SFTableViewHeaderCell";
NSString * const kTableViewSmartfeedRTLHeaderReuseId = @"SFTableViewRTLHeaderCell";
NSString * const kTableViewHorizontalCarouselWithTitleReuseId = @"SFCarouselWithTitleReuseId";
NSString * const kTableViewHorizontalCarouselNoTitleReuseId = @"SFCarouselNoTitleReuseId";
NSString * const kTableViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleTableViewCell";
NSString * const kTableViewHorizontalFixedWithTitleReuseId = @"SFHorizontalFixedWithTitleTableViewCell";
NSString * const kTableViewSingleWithTitleReuseId = @"SFSingleWithTitleTableViewCell";
NSString * const kTableViewSingleWithThumbnailReuseId = @"SFSingleWithThumbnailTableCell";
NSString * const kTableViewSingleWithThumbnailWithTitleReuseId = @"SFSingleWithThumbnailWithTitleTableCell";
NSString * const kTableViewSingleVideoReuseId = @"kTableViewSingleVideoReuseId";
NSString * const kTableViewSingleVideoWithTitleReuseId = @"SFSingleVideoWithTitleTableViewCell";
NSString * const kTableViewSingleVideoNoTitleReuseId = @"SFSingleVideoNoTitleTableViewCell";
NSString * const kTableViewHorizontalFixedWithVideoCellReuseId = @"SFHorizontalFixedWithVideoTableViewCell";
NSString * const kTableViewHorizontalFixedWithTitleWithVideoCellReuseId = @"SFHorizontalFixedWithTitleWithVideoTableViewCell";

- (id _Nonnull )initWithTableView:(UITableView * _Nonnull)tableView {
    self = [super init];
    if(self) {
        NSLog(@"_init: %@", self);
        
        self.tableView = tableView;
        tableView.estimatedRowHeight = kTableViewRowHeight;
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        // horizontal cell (carousel container) SFCarouselContainerCell
        // horizontal cells
        UINib *horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCarouselWithTitleTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalCarouselWithTitleTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalCarouselWithTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalCarouselNoTitleTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalCarouselNoTitleTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalCarouselNoTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedNoTitleTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedNoTitleTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalFixedNoTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedWithTitleTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedWithTitleTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalFixedWithTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedWithVideoTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedWithVideoTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalFixedWithVideoCellReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFHorizontalFixedWithTitleWithVideoTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFHorizontalFixedWithTitleWithVideoTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewHorizontalFixedWithTitleWithVideoCellReuseId];
        
        // Smartfeed header cell
        UINib *nib = [UINib nibWithNibName:@"SFTableViewHeaderCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewHeaderCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSmartfeedHeaderReuseId];
        
        nib = [UINib nibWithNibName:@"SFTableViewRTLHeaderCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewRTLHeaderCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSmartfeedRTLHeaderReuseId];
        
        // video cell
        [self.tableView registerClass:[SFVideoTableViewCell class] forCellReuseIdentifier:kTableViewSingleVideoReuseId];
        
        // single item cell
        nib = [UINib nibWithNibName:@"SFTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleWithTitleTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleWithTitleTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleWithTitleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleWithThumbnailTableCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleWithThumbnailTableCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleWithThumbnailReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleWithThumbnailWithTitleTableCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleWithThumbnailWithTitleTableCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleWithThumbnailWithTitleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleVideoNoTitleTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleVideoNoTitleTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleVideoNoTitleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleVideoWithTitleTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleVideoWithTitleTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleVideoWithTitleReuseId];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(orientationChanged:)
            name:UIDeviceOrientationDidChangeNotification
            object:[UIDevice currentDevice]];
    }
    return self;
}

- (void) orientationChanged:(NSNotification *)note
{
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        return;
    }
    UITableView *tableView = self.tableView;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        NSArray *visibleIndexPathArray = [tableView indexPathsForVisibleRows];
        [tableView reloadRowsAtIndexPaths:visibleIndexPathArray withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

- (void) registerSingleItemNib:( UINib * _Nonnull )nib forCellWithReuseIdentifier:( NSString * _Nonnull )identifier {
    if (self.tableView != nil) {
        [self.tableView registerNib:nib forCellReuseIdentifier:identifier];
    }
}

#pragma mark - UITableView methods
- (UITableViewCell *)tableView:(UITableView *)tableView headerCellForRowAtIndexPath:(NSIndexPath *)indexPath isRTL:(BOOL)isRTL {
    NSString * const reuseId = isRTL ? kTableViewSmartfeedRTLHeaderReuseId : kTableViewSmartfeedHeaderReuseId;
    return [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath sfItemType:(SFItemType)sfItemType {
    switch (sfItemType) {
        case SFTypeStripNoTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewSingleReuseId forIndexPath:indexPath];
        case SFTypeCarouselWithTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalCarouselWithTitleReuseId forIndexPath:indexPath];
        case SFTypeCarouselNoTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalCarouselNoTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowNoTitle:
        case SFTypeGridThreeInRowNoTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalFixedNoTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithTitle:
        case SFTypeGridThreeInRowWithTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalFixedWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripWithTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripWithThumbnailNoTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleWithThumbnailReuseId forIndexPath:indexPath];
        case SFTypeStripWithThumbnailWithTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleWithThumbnailWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripVideo:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleVideoReuseId forIndexPath:indexPath];
        case SFTypeStripVideoWithPaidRecAndTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleVideoWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripVideoWithPaidRecNoTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleVideoNoTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithVideo:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewHorizontalFixedWithVideoCellReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithTitleWithVideo:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewHorizontalFixedWithTitleWithVideoCellReuseId forIndexPath:indexPath];
        default:
            NSAssert(false, @"sfItem.itemType must be covered in this switch/case statement");
            return [[UITableViewCell alloc] init];
    }
}

- (CGFloat) heightForRowAtIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem {
    SFItemType sfItemType = sfItem.itemType;
    CGFloat screenWidth = self.tableView.frame.size.width;
    
    if (sfItemType == SFTypeGridThreeInRowNoTitle) {
        return 280.0;
    }
    else if (sfItemType == SFTypeGridTwoInRowNoTitle ||
             sfItemType == SFTypeCarouselWithTitle ||
             sfItemType == SFTypeCarouselNoTitle ||
             sfItemType == SFTypeGridTwoInRowWithVideo) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 350.0 : kTableViewRowHeight;
    }
    else if (sfItemType == SFTypeGridTwoInRowWithTitle ||
             sfItemType == SFTypeStripVideoWithPaidRecAndTitle ||
             sfItemType == SFTypeGridTwoInRowWithTitleWithVideo) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 450.0 : 270.0;
    }
    else if (sfItemType == SFTypeStripWithTitle || sfItemType == SFTypeStripVideoWithPaidRecAndTitle) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2*(screenWidth/3) : 280.0;
    }
    else if (sfItemType == SFTypeStripWithThumbnailNoTitle) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 180.0 : 120.0;
    }
    else if (sfItemType == SFTypeStripWithThumbnailWithTitle) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 210.0 : 150.0;
    }
    else if (sfItemType == SFTypeStripVideo) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 350.0 : 250.0;
    }

    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2*(screenWidth/3) : kTableViewRowHeight;
}

- (void) configureVideoCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem {
    SFVideoTableViewCell *videoCell = (SFVideoTableViewCell *)cell;
    [self configureSingleTableViewCell:videoCell atIndexPath:indexPath withSFItem:sfItem];
    
    if ([self.eventListenerTarget respondsToSelector:@selector(isVideoCurrentlyPlaying)] &&
        self.eventListenerTarget.isVideoCurrentlyPlaying) {
        return;
    }
    
    BOOL shouldReturn = [SFUtils configureGenericVideoCell:videoCell sfItem:sfItem];
    if (shouldReturn) {
        return;
    }
    videoCell.webview = [SFUtils createVideoWebViewInsideView:videoCell.cardContentView withSFItem:sfItem scriptMessageHandler:videoCell.wkScriptMessageHandler uiDelegate:self.wkWebviewDelegate withHorizontalMargin:NO];
    
    [SFUtils loadVideoURLIn:videoCell sfItem:sfItem];
}

- (void) configureSingleTableViewCell:(SFTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withSFItem:(SFItemData *)sfItem {
    SFTableViewCell *singleCell = (SFTableViewCell *)cell;
    const NSInteger cellTag = indexPath.row;
    singleCell.tag = cellTag;
    singleCell.contentView.tag = cellTag;
    if (singleCell.cardContentView) {
        singleCell.cardContentView.tag = cellTag;
    }
    
    if (!sfItem.isCustomUI) {
        singleCell.backgroundColor = [[SFUtils sharedInstance] primaryBackgroundColor];
        singleCell.cardContentView.backgroundColor = [[SFUtils sharedInstance] primaryBackgroundColor];
    }
    
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
    if (!sfItem.isCustomUI) {
        singleCell.recTitleLabel.textColor = [[SFUtils sharedInstance] titleColor:[rec isPaidLink]];
        singleCell.recSourceLabel.textColor = [[SFUtils sharedInstance] subtitleColor];
    }
    [SFUtils removePaidLabelFromImageView:singleCell.recImageView];
    
    if ([rec isPaidLink]) {
        if ([rec shouldDisplayDisclosureIcon]) {
            singleCell.adChoicesButton.hidden = NO;
            singleCell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            singleCell.adChoicesButton.tag = cellTag;
            [[SFImageLoader sharedInstance] loadImage:rec.disclosure.imageUrl intoButton:singleCell.adChoicesButton];
            NSAssert(self.eventListenerTarget != nil, @"clickListenerTarget must not be nil");
            [singleCell.adChoicesButton addTarget:self.eventListenerTarget action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
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
        }
        if (!sfItem.isCustomUI && !self.displaySourceOnOrganicRec) {
            singleCell.recSourceLabel.text = @"";
        }
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:singleCell.recImageView];
    
    if ((sfItem.itemType == SFTypeStripWithTitle) ||
        (sfItem.itemType == SFTypeStripWithThumbnailWithTitle) ||
        (sfItem.itemType == SFTypeStripVideoWithPaidRecAndTitle))
    {
        if (sfItem.widgetTitle) {
            singleCell.cellTitleLabel.text = sfItem.widgetTitle;
        }
        else {
            // fallback
            singleCell.cellTitleLabel.text = @"Around the web";
        }
        if (!sfItem.isCustomUI) {
            singleCell.cellTitleLabel.textColor = [[SFUtils sharedInstance] subtitleColor];
        }
    }
    if (!self.disableCellShadows) {
        if ([rec isPaidLink] && (sfItem.shadowColor != nil)) {
            [SFUtils addDropShadowToView: singleCell shadowColor:sfItem.shadowColor];
        }
        else {
            [SFUtils addDropShadowToView: singleCell];
        }
    }
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.eventListenerTarget  action:@selector(recommendationClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    if (singleCell.cardContentView) {
        [singleCell.cardContentView addGestureRecognizer:tapGesture];
    }
    else {
        [singleCell.contentView addGestureRecognizer:tapGesture];
    }
}

@end
