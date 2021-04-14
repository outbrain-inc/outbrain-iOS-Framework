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
#import "SFTableViewReadMoreCell.h"
#import "SFUtils.h"
#import "SFImageLoader.h"
#import "SFVideoTableViewCell.h"
#import "SFReadMoreModuleHelper.h"
#import "OBDisclosure.h"

@interface SFTableViewManager() <UIGestureRecognizerDelegate>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation SFTableViewManager

const CGFloat kTableViewRowHeight = 250.0;
NSString * const kTableViewSingleReuseId = @"SFTableViewCell";
NSString * const kTableViewSmartfeedHeaderReuseId = @"SFTableViewHeaderCell";
NSString * const kTableViewReadMoreCellReuseId = @"SFTableViewReadMoreCell";
NSString * const kTableViewSmartfeedRTLHeaderReuseId = @"SFTableViewRTLHeaderCell";
NSString * const kTableViewHorizontalCarouselWithTitleReuseId = @"SFCarouselWithTitleReuseId";
NSString * const kTableViewHorizontalCarouselNoTitleReuseId = @"SFCarouselNoTitleReuseId";
NSString * const kTableViewHorizontalFixedNoTitleReuseId = @"SFHorizontalFixedNoTitleTableViewCell";
NSString * const kTableViewHorizontalFixedWithTitleReuseId = @"SFHorizontalFixedWithTitleTableViewCell";
NSString * const kTableViewBrandedCarouselWithTitleReuseId = @"SFBrandedCarouselTableViewCell";
NSString * const kTableViewWeeklyHighlightsWithTitleReuseId = @"SFWeeklyHighlightsTableViewCell";
NSString * const kTableViewSingleWithTitleReuseId = @"SFSingleWithTitleTableViewCell";
NSString * const kTableViewSingleAppInstallReuseId = @"SFSingleAppInstallTableCell";
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
        
        horizontalCellNib = [UINib nibWithNibName:@"SFBrandedCarouselTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFBrandedCarouselTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewBrandedCarouselWithTitleReuseId];
        
        horizontalCellNib = [UINib nibWithNibName:@"SFWeeklyHighlightsTableViewCell" bundle:bundle];
        NSAssert(horizontalCellNib != nil, @"SFWeeklyHighlightsTableViewCell should not be null");
        [self.tableView registerNib:horizontalCellNib forCellReuseIdentifier: kTableViewWeeklyHighlightsWithTitleReuseId];
        
        // Smartfeed header cell
        UINib *nib = [UINib nibWithNibName:@"SFTableViewHeaderCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewHeaderCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSmartfeedHeaderReuseId];
        
        nib = [UINib nibWithNibName:@"SFTableViewRTLHeaderCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewRTLHeaderCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSmartfeedRTLHeaderReuseId];
        
        // Read More module cell
        nib = [UINib nibWithNibName:@"SFTableViewReadMoreCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewReadMoreCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewReadMoreCellReuseId];
        
        // video cell
        [self.tableView registerClass:[SFVideoTableViewCell class] forCellReuseIdentifier:kTableViewSingleVideoReuseId];
        
        // single item cell
        nib = [UINib nibWithNibName:@"SFTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleWithTitleTableViewCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleWithTitleTableViewCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleWithTitleReuseId];
        
        nib = [UINib nibWithNibName:@"SFSingleAppInstallTableCell" bundle:bundle];
        NSAssert(nib != nil, @"SFSingleAppInstallTableCell should not be null");
        [self registerSingleItemNib:nib forCellWithReuseIdentifier: kTableViewSingleAppInstallReuseId];
        
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
        if ([tableView superview] == nil) {
            return;
        }
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
    NSString *reuseId = isRTL ? kTableViewSmartfeedRTLHeaderReuseId : kTableViewSmartfeedHeaderReuseId;
    // https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/TestingYourInternationalApp/TestingYourInternationalApp.html#//apple_ref/doc/uid/10000171i-CH7-SW3
    // if the app already supports RTL - auto switching xib layout constrains direction - we can just use the default xib anyway.
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        reuseId = kTableViewSmartfeedHeaderReuseId;
    }
    
    return [tableView dequeueReusableCellWithIdentifier:reuseId forIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView readMoreCellAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = kTableViewReadMoreCellReuseId;
    
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
        case SFTypeBrandedCarouselWithTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewBrandedCarouselWithTitleReuseId forIndexPath:indexPath];
        case SFTypeWeeklyHighlightsWithTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewWeeklyHighlightsWithTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowNoTitle:
        case SFTypeGridThreeInRowNoTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalFixedNoTitleReuseId forIndexPath:indexPath];
        case SFTypeGridTwoInRowWithTitle:
        case SFTypeGridThreeInRowWithTitle:
            return [tableView dequeueReusableCellWithIdentifier: kTableViewHorizontalFixedWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripWithTitle:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleWithTitleReuseId forIndexPath:indexPath];
        case SFTypeStripAppInstall:
            return [tableView dequeueReusableCellWithIdentifier:kTableViewSingleAppInstallReuseId forIndexPath:indexPath];
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
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (sfItemType == SFTypeGridThreeInRowNoTitle || sfItemType == SFTypeGridThreeInRowWithTitle) {
        CGFloat EXTRA_FOR_HEADER = (sfItemType == SFTypeGridThreeInRowWithTitle) ? 60 : 0;
        return EXTRA_FOR_HEADER + 280.0;
    }
    else if (sfItemType == SFTypeGridTwoInRowNoTitle ||
             sfItemType == SFTypeCarouselNoTitle ||
             sfItemType == SFTypeGridTwoInRowWithVideo) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 350.0 : 220.0;
    }
    else if (sfItemType == SFTypeBrandedCarouselWithTitle || sfItemType == SFTypeStripAppInstall) {
        return MAX(screenHeight*0.62, 450);
    }
    else if (sfItemType == SFTypeCarouselWithTitle) {
        return MAX(screenHeight*0.62, 300);
    }
    else if (sfItemType == SFTypeWeeklyHighlightsWithTitle) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return screenWidth * 0.86;
        } else {
            return screenWidth * 1.35;
        }
    }
    else if (sfItemType == SFTypeGridTwoInRowWithTitle ||
             sfItemType == SFTypeStripVideoWithPaidRecAndTitle ||
             sfItemType == SFTypeGridTwoInRowWithTitleWithVideo) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 450.0 : 290.0;
    }
    else if (sfItemType == SFTypeStripWithTitle || sfItemType == SFTypeStripVideoWithPaidRecAndTitle) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 2*(screenWidth/3) : 360.0;
    }
    else if (sfItemType == SFTypeStripNoTitle) {
        return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 180.0 : 310.0;
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
    singleCell.recSourceLabel.text = [SFUtils getSourceTextForRec:rec withSettings:sfItem.odbSettings];
    if (!sfItem.isCustomUI && sfItem.itemType != SFTypeStripAppInstall) {
        singleCell.recTitleLabel.textColor = [[SFUtils sharedInstance] titleColor:[rec isPaidLink]];
        singleCell.recSourceLabel.textColor = [[SFUtils sharedInstance] subtitleColor: sfItem.odbSettings.abSourceFontColor];
        [SFUtils setFontSizeForTitleLabel:singleCell.recTitleLabel andSourceLabel:singleCell.recSourceLabel withAbTestSettings:sfItem.odbSettings];
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
            [[SFImageLoader sharedInstance] loadImageUrl:rec.publisherLogoImage.url into:singleCell.publisherLogo];
            singleCell.publisherLogoWidth.constant = rec.publisherLogoImage.width;
            singleCell.publisherLogoHeight.constant = rec.publisherLogoImage.height;
        }
        if (!sfItem.isCustomUI && !self.displaySourceOnOrganicRec) {
            singleCell.recSourceLabel.text = @"";
        }
    }
    
    NSInteger abTestDuration = sfItem.odbSettings.abImageFadeAnimation ? sfItem.odbSettings.abImageFadeDuration : -1;
    [[SFImageLoader sharedInstance] loadRecImage:rec.image into:singleCell.recImageView withFadeDuration:abTestDuration];
    
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
            singleCell.cellTitleLabel.textColor = [[SFUtils sharedInstance] titleColor];
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                singleCell.cellTitleLabel.font = [singleCell.cellTitleLabel.font fontWithSize: 22.0];
            }
        }
    }
    else if (sfItem.itemType == SFTypeStripAppInstall) {
        singleCell.cellTitleLabel.text = sfItem.widgetTitle;
        singleCell.cellTitleLabel.textColor = [SFUtils sharedInstance].darkMode ? UIColor.whiteColor : [SFUtils colorFromHexString:@"#717075"];
        singleCell.recTitleLabel.textColor =  [SFUtils sharedInstance].darkMode ? UIColor.whiteColor : [SFUtils colorFromHexString:@"#717075"];
        
        [[SFImageLoader sharedInstance] loadImageUrl:sfItem.odbSettings.brandedCarouselSettings.image.url into:singleCell.cellBrandLogoImageView]; // top right image
        
        if (singleCell.brandedCtaButtonLabel) {
            singleCell.brandedCtaButtonLabel.layer.borderWidth = 1.0;
            singleCell.brandedCtaButtonLabel.layer.borderColor = UIColorFromRGB(0x4a90e2).CGColor;
            singleCell.brandedCtaButtonLabel.layer.backgroundColor = UIColorFromRGB(0x4a90e2).CGColor;
            singleCell.brandedCtaButtonLabel.layer.cornerRadius = 4.0;
        }
        if (singleCell.cellBrandLogoImageView) {
            singleCell.cellBrandLogoImageView.layer.cornerRadius = 8.0;
        }
    }
    
    if (sfItem.itemType == SFTypeStripWithTitle || sfItem.itemType == SFTypeStripNoTitle) {
        [self configureCtaLabelInCell:singleCell withCtaText:rec.ctaText isCustomUI:sfItem.isCustomUI shouldShowCtaButton:sfItem.odbSettings.shouldShowCtaButton];
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

- (void) configureCtaLabelInCell:(SFTableViewCell *)singleCell withCtaText:(NSString *) ctaText isCustomUI:(BOOL) isCustomUI shouldShowCtaButton:(BOOL) shouldShowCtaButton  {
    NSInteger ctaLabelTag = 112233445566;
    UILabel * existingCtaLabelView = [singleCell viewWithTag:ctaLabelTag];
    if (existingCtaLabelView != nil) { // CTA view exists
        // Remove existing CTA view
        [existingCtaLabelView removeFromSuperview];
        
        // Add constraint for rec title view
        NSLayoutConstraint *recTitleTrailingConstraint = [[singleCell.recTitleLabel trailingAnchor] constraintEqualToAnchor:[singleCell trailingAnchor] constant:-8];
        recTitleTrailingConstraint.identifier = @"recTitleTrailingConstraint";
        recTitleTrailingConstraint.active = YES;
    }
    
    // No CTA label to show or custom-ui or disabled by settings
    if (ctaText == nil || [ctaText isEqual: @""] || isCustomUI || !shouldShowCtaButton) {
        [singleCell.recTitleLabel layoutIfNeeded];
        return;
    }
    
    UILabel * ctaLabelView = [SFUtils getRecCtaLabelWithText: ctaText];
    
    ctaLabelView.tag = ctaLabelTag;
    [singleCell addSubview:ctaLabelView];
    
    ctaLabelView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Remove existing constraints of storyboard
    for (NSLayoutConstraint *constraint in singleCell.recTitleLabel.superview.constraints) {
        if ((constraint.secondAttribute == NSLayoutAttributeTrailing &&
             constraint.secondItem == singleCell.recTitleLabel)) {
            [singleCell.recTitleLabel.superview removeConstraint:constraint];
        }
    }
    
    // Remove existing constraints added programmatically
    for (NSLayoutConstraint *constraint in singleCell.constraints) {
        if ([constraint.identifier isEqual: @"recTitleTrailingConstraint"]) {
            [singleCell removeConstraint:constraint];
        }
    }
    
    // Set CTA view constraints
    [[singleCell.recTitleLabel trailingAnchor] constraintEqualToAnchor:[ctaLabelView leadingAnchor] constant:-12].active = YES;
    [[ctaLabelView widthAnchor] constraintEqualToConstant:ctaLabelView.intrinsicContentSize.width + 12].active = YES;
    NSInteger trailingConstant = 8;
    [[singleCell trailingAnchor] constraintEqualToAnchor:[ctaLabelView trailingAnchor] constant:trailingConstant].active = YES;
    [[ctaLabelView heightAnchor] constraintEqualToConstant:25].active = YES;
    [[ctaLabelView topAnchor] constraintEqualToAnchor:[singleCell.recTitleLabel topAnchor] constant:3].active = YES;
    
    [ctaLabelView layoutIfNeeded];
}

- (void) configureReadMoreTableViewCell:(UITableViewCell *)cell withButtonText:(NSString * _Nonnull)buttonText; {
    SFTableViewReadMoreCell *readMoreCell = (SFTableViewReadMoreCell *)cell;
    
    readMoreCell.backgroundColor = [[SFUtils sharedInstance] primaryBackgroundColor];
    
    readMoreCell.readMoreLabel.text = buttonText;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self.eventListenerTarget action:@selector(readMoreButtonClicked:)];
    tapGesture.numberOfTapsRequired = 1;
    [readMoreCell.readMoreLabel addGestureRecognizer:tapGesture];
}

@end
