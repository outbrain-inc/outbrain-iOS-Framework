//
//  OBClassicRecommendationsView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/16/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBClassicRecommendationsView.h"
#import "OBDemoDataHelper.h"

#import <OutbrainSDK/OutbrainSDK.h>

@interface OBClassicRecommendationsView () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

/**
 *  Discussion:
 *      Use UICollecitonView to layout our recommendations
 **/
@property (nonatomic, strong) UICollectionView * internalCollectionView;
@end

// Define our reuse identifier
static NSString * RecommendationCellID = @"RecommendationCellID";
static NSString * BrandingHeaderID = @"BrandingHeaderID";


// Our Cell class for holding the views for us
@interface OBRecommendationCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * sourceLabel;
@property (nonatomic, assign, getter = isInitialized) BOOL initialized;
@end

@implementation OBRecommendationCell @end



/**
 *  Discussion:
 *      This is our actual recommendationsView implementation
 **/
@implementation OBClassicRecommendationsView


NSInteger const kCellTitleLabelNumberOfLines = 3;
NSInteger const kCellSourceLabelNumberOfLines = 2;
NSInteger const kNumberOfLinesAsNeeded = 0;


#pragma mark - Initialize

- (void)commonInit
{
    // Create our collectionView here
    UICollectionViewFlowLayout * layout = [UICollectionViewFlowLayout new];
    layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
    layout.headerReferenceSize = CGSizeMake(self.bounds.size.width, 30);
    layout.itemSize = CGSizeMake(self.bounds.size.width-20.f, 60.f);
    
    
    self.internalCollectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.internalCollectionView.scrollsToTop = NO;
    self.internalCollectionView.backgroundColor = self.backgroundColor;
    self.internalCollectionView.delegate = self;
    self.internalCollectionView.dataSource = self;
    self.internalCollectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.internalCollectionView registerClass:[OBRecommendationCell class] forCellWithReuseIdentifier:RecommendationCellID];
    [self.internalCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:BrandingHeaderID];
    [self addSubview:self.internalCollectionView];
    
    
    // Set our default values here
    self.showImages = YES;
    self.layoutType = OBClassicRecommendationsViewLayoutTypeList;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame
{ if((self=[super initWithFrame:frame]))[self commonInit]; return self; }

- (id)initWithCoder:(NSCoder *)aDecoder
{ if((self=[super initWithCoder:aDecoder]))[self commonInit]; return self; }


#pragma mark - Getters

- (NSInteger)numberOfRecommendationsToLayout
{
    return _recommendationResponse.recommendations.count;
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.internalCollectionView.backgroundColor = backgroundColor;
}

- (void)setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse
{
    // No need to do anything if the recommendation responses are equal
    if([recommendationResponse isEqual:_recommendationResponse]) return;
    
    _recommendationResponse = recommendationResponse;
    
    [self.internalCollectionView reloadData];
}


#pragma mark - Collection View

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self numberOfRecommendationsToLayout];
}

// Recommended by label
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
        // We want our recommendations header at the top
        UICollectionReusableView * brandingHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:BrandingHeaderID forIndexPath:indexPath];
        
        // So we're not blindly typing in numbers let's define our tags
        typedef enum {
            AlsoOnTheWebTag = 100,
            AmeliaHeadLogoTag = 102
        } NSInteger;
        
        // Get the labels
        OBLabel * alsoOnTheWebLabel = (OBLabel *)[brandingHeader viewWithTag:AlsoOnTheWebTag];
        UIButton * brandingImageButton = (UIButton *)[brandingHeader viewWithTag:AmeliaHeadLogoTag];
        
        // If not available create them
        if(!alsoOnTheWebLabel)
        {
            alsoOnTheWebLabel = [Outbrain getOBLabelForWidget: @"APP_1"];
            alsoOnTheWebLabel.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.000];
            alsoOnTheWebLabel.backgroundColor = [UIColor clearColor];
            alsoOnTheWebLabel.font = [UIFont boldSystemFontOfSize:12];
            alsoOnTheWebLabel.tag = AlsoOnTheWebTag;
            alsoOnTheWebLabel.text = @"Recommended to you";
            [alsoOnTheWebLabel sizeToFit];
            [brandingHeader addSubview:alsoOnTheWebLabel];
            
            brandingImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
            brandingImageButton.tag = AmeliaHeadLogoTag;
            [brandingImageButton addTarget:self action:@selector(brandingTapAction:) forControlEvents:UIControlEventTouchUpInside];
            [brandingImageButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
            CGRect r = CGRectMake(0, 0, 71, 18);
            r.origin.y = (brandingHeader.frame.size.height - r.size.height) / 2.f;
            r.origin.x = (brandingHeader.frame.size.width - r.size.width - 5.f);
            brandingImageButton.frame = r;
            [brandingHeader addSubview:brandingImageButton];
        }
        
        CGFloat centerY = brandingHeader.frame.size.height/2.f;
        alsoOnTheWebLabel.center = CGPointMake(10.f + (alsoOnTheWebLabel.frame.size.width/2.f), centerY);
        brandingImageButton.center = CGPointMake(CGRectGetWidth(brandingHeader.frame) - (brandingImageButton.frame.size.width/2.f) - 10.f, CGRectGetMaxY(alsoOnTheWebLabel.frame) - (brandingImageButton.bounds.size.height/2.f));
        return brandingHeader;
    }
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OBRecommendationCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:RecommendationCellID forIndexPath:indexPath];
    
    if(!cell.initialized)
    {
        [self _setupSubviewsForCell:cell];
    }
    
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
    
    cell.titleLabel.text = recommendation.content;
    NSString * source = (recommendation.source ? recommendation.source : recommendation.author);
    cell.sourceLabel.text = [NSString stringWithFormat:@"(%@)",source];
    
    if(self.showImages)
    {
        typeof(cell) __weak __cell = cell;
        [self fetchImageForURL:recommendation.image.url withCallback:^(UIImage *image) {
            [__cell.imageView setImage:image];
        }];
    }
    
    
    // Setup framing and positioning
    if(_layoutType == OBClassicRecommendationsViewLayoutTypeGrid)
    {
        cell.imageView.center = CGPointMake(cell.bounds.size.width/2.f, cell.imageView.bounds.size.height/2.f);
    }
    
    CGFloat xOff = (_layoutType == OBClassicRecommendationsViewLayoutTypeGrid) ? 5.f : CGRectGetMaxX(cell.imageView.frame) + 5.f;
    CGFloat yOff = (_layoutType == OBClassicRecommendationsViewLayoutTypeGrid) ? CGRectGetMaxY(cell.imageView.frame) + 5.f : 5.f;
    
    if(!self.showImages)
    {
        xOff = 5.f;
        yOff = 5.f;
    }
    
    cell.imageView.hidden = !self.showImages;
    
    cell.titleLabel.frame = CGRectMake(xOff + 5.f, yOff, cell.frame.size.width - xOff - 5.f, cell.bounds.size.height);
    [cell.titleLabel sizeToFit];
    cell.titleLabel.center = CGPointMake(xOff + CGRectGetMidX(cell.titleLabel.bounds),yOff + CGRectGetMidY(cell.titleLabel.bounds));
    
    cell.sourceLabel.frame = CGRectMake(xOff + 5.f, yOff, cell.frame.size.width - xOff - 5.f, cell.bounds.size.height);
    [cell.sourceLabel sizeToFit];
    cell.sourceLabel.center = CGPointMake(xOff + CGRectGetMidX(cell.sourceLabel.bounds), CGRectGetMidY(cell.sourceLabel.bounds) + CGRectGetMaxY(cell.titleLabel.frame));
    
    
    // This ensures that our selectedView will show on top of our content.
    [cell bringSubviewToFront:cell.selectedBackgroundView];
    
    return cell;
}

- (CGFloat) getWidthForTitleLabelAndSourceLabel {
    UICollectionViewFlowLayout * l = (UICollectionViewFlowLayout *)self.internalCollectionView.collectionViewLayout;
    CGSize itemSize = l.itemSize;
    CGFloat xOff = (_layoutType == OBClassicRecommendationsViewLayoutTypeGrid || !self.showImages) ? 5.f : itemSize.height + 5.f;
    return itemSize.width - xOff - 5.f;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeMake(self.bounds.size.width - 20.f, 30);
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
    CGFloat maxWidth = self.bounds.size.width;
    CGFloat height = [self calculateHightForRecommandation:recommendation];
    
    if (self.layoutType == OBClassicRecommendationsViewLayoutTypeGrid)
    {
        // Portrait is 2 accross, landscape is 3
        maxWidth = self.bounds.size.width / (UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation) ? 3.f : 2.f);
    }
    
    CGSize itemSize = CGSizeMake(maxWidth-20.f, height);
    
    return itemSize;
}

- (CGFloat) getHeight {
    UICollectionViewFlowLayout * l = (UICollectionViewFlowLayout *)self.internalCollectionView.collectionViewLayout;
    return [l collectionViewContentSize].height;
}

// Setup our (images,labels,colors, etc...) if necessary
- (void)_setupSubviewsForCell:(OBRecommendationCell *)cell
{
    BOOL isLayoutTypeGrid = (_layoutType == OBClassicRecommendationsViewLayoutTypeGrid);
    UICollectionViewFlowLayout * l = (UICollectionViewFlowLayout *)self.internalCollectionView.collectionViewLayout;
    CGSize itemSize = l.itemSize;
    
    cell.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, itemSize.height, itemSize.height)];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.imageView.layer.borderWidth = 1.f;
    cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [cell.contentView addSubview:cell.imageView];
    
    cell.titleLabel = [UILabel new];
    cell.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
    cell.titleLabel.numberOfLines = isLayoutTypeGrid ? kCellTitleLabelNumberOfLines : kNumberOfLinesAsNeeded;
    cell.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    cell.titleLabel.backgroundColor = [UIColor clearColor];
    cell.titleLabel.textColor = [UIColor blackColor];
    cell.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [cell.contentView addSubview:cell.titleLabel];
    
    cell.sourceLabel = [UILabel new];
    cell.sourceLabel.backgroundColor = [UIColor clearColor];
    cell.sourceLabel.font = [UIFont systemFontOfSize:12];
    cell.sourceLabel.textColor = [UIColor darkGrayColor];
    cell.sourceLabel.numberOfLines = isLayoutTypeGrid ? kCellSourceLabelNumberOfLines : kNumberOfLinesAsNeeded;
    cell.sourceLabel.lineBreakMode = NSLineBreakByTruncatingTail;

    [cell.contentView addSubview:cell.sourceLabel];
    
    cell.initialized = YES;
    
    UIView * v = [[UIView alloc] initWithFrame:cell.bounds];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    v.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.3f];
    cell.selectedBackgroundView = v;
    
    cell.contentView.backgroundColor = [UIColor colorWithRed:0.969 green:0.969 blue:0.969 alpha:1.000];
}

// Simple image fetching with GCD
- (void)fetchImageForURL:(NSURL *)url withCallback:(void (^)(UIImage *))callback
{
    if(!self.showImages) return;
    
    BOOL (^ReturnHandler)(UIImage *) = ^(UIImage *returnImage) {
        if(!returnImage) return NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(returnImage);
        });
        return YES;
    };
    
    __block UIImage * responseImage = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSString * key = @([url.absoluteString hash]).stringValue;
        // Next check if the image is on disk.  If it is then we'll go ahead and add it to the cache and return from the cache
        NSString * cachesDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/com.ob.images"];
        NSFileManager * fm = [[NSFileManager alloc] init];
        [fm createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        NSString * diskCachePath = [cachesDir stringByAppendingPathComponent:key];
        
        // We have this on disk.
        responseImage = [UIImage imageWithContentsOfFile:diskCachePath];
        if(!ReturnHandler(responseImage))
        {
            // Fetch the image
            NSData * d = [NSData dataWithContentsOfURL:url];
            if(d)
            {
                responseImage = [UIImage imageWithData:d];
                ReturnHandler(responseImage);
            }
        }
    });
}


#pragma mark - Selection

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Selected an outbrain recommendation
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    OBRecommendation * recommendation = self.recommendationResponse.recommendations[indexPath.row];
    
    if(self.recommendationTapHandler)
    {
        self.recommendationTapHandler(recommendation);
    }
    if(self.widgetDelegate)
    {
        [self.widgetDelegate widgetView:self tappedRecommendation:recommendation];
    }
}

- (void)brandingTapAction:(id)sender
{
    if(self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}


#pragma mark - Rotation
- (void)willRotate:(NSNotification *)note
{
    [self.internalCollectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - Private
-(CGFloat) calculateHightForRecommandation:(OBRecommendation *)recommenationItem {
    CGFloat height = 0;
    CGFloat labelWidth = 0;
    BOOL isLayoutTypeGrid = (_layoutType == OBClassicRecommendationsViewLayoutTypeGrid);
    UICollectionViewFlowLayout * l = (UICollectionViewFlowLayout *)self.internalCollectionView.collectionViewLayout;
    CGSize itemSize = l.itemSize;
    CGFloat minHeight = itemSize.height;
    
    if (self.showImages && (self.layoutType == OBClassicRecommendationsViewLayoutTypeGrid)) {
        // add image height
        height += itemSize.height;
    }
    
    
    // add titleLabel height
    if (isLayoutTypeGrid) {
        labelWidth = self.bounds.size.width / (UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation) ? 3.f : 2.f);

        labelWidth -= 30.0; // width of the cell minus the padding between cells (20.0) and the padding the label has on each side (10.0)
    }
    else {
       labelWidth = [self getWidthForTitleLabelAndSourceLabel];
    }
    
    NSString *longText = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.";
    
    UILabel *gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont boldSystemFontOfSize:14];
    if (isLayoutTypeGrid) {
        gettingSizeLabel.text = longText;
        gettingSizeLabel.numberOfLines = kCellTitleLabelNumberOfLines;
    }
    else {
        gettingSizeLabel.text = recommenationItem.content;
        gettingSizeLabel.numberOfLines = kNumberOfLinesAsNeeded;
    }
    
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(labelWidth, 9999);
    CGSize expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    height += expectSize.height + 5.0; // + yOffset

    
    // add sourceLabel height
    gettingSizeLabel = [[UILabel alloc] init];
    gettingSizeLabel.font = [UIFont systemFontOfSize:12];
    if (isLayoutTypeGrid) {
        gettingSizeLabel.text = longText;
        gettingSizeLabel.numberOfLines = kCellSourceLabelNumberOfLines;
    }
    else {
        gettingSizeLabel.text = recommenationItem.source;
        gettingSizeLabel.numberOfLines = kNumberOfLinesAsNeeded;
    }
    
    gettingSizeLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    maximumLabelSize = CGSizeMake(labelWidth, 9999);
    expectSize = [gettingSizeLabel sizeThatFits:maximumLabelSize];
    
    height += expectSize.height;
    
    
    if (isLayoutTypeGrid && UIInterfaceOrientationIsLandscape(self.window.rootViewController.interfaceOrientation)) {
        height += 25.0;
    }
    else {
        height += 10.0;
    }

    return (height < minHeight) ? minHeight : height;
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
