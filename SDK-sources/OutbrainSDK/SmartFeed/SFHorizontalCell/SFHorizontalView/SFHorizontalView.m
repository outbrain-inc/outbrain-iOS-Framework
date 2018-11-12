//
//  SFHorizontalView.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalView.h"
#import <OutbrainSDK/OutbrainSDK.h>
#import "SFUtils.h"
#import "SFCollectionViewCell.h"
#import "SFImageLoader.h"

@interface SFHorizontalView() <UICollectionViewDataSource, UICollectionViewDelegate>



@end

@implementation SFHorizontalView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.itemSize = CGSizeMake(256, 360);
        self.didInitCollectionViewLayout = NO;
    }
    return self;
}

-(void) setupView {
    if (self.didInitCollectionViewLayout) {
        return;
    }
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGRect collectionViewframe = CGRectMake(0, 0, screenWidth, self.frame.size.height);
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.didInitCollectionViewLayout = YES;
    self.collectionView = [[UICollectionView alloc] initWithFrame: collectionViewframe collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    [self addSubview:self.collectionView];
    
    [SFUtils addConstraintsToFillParent:self.collectionView];
    [self setNeedsLayout];
    
    // NSLog(@"SFHorizontalView - setupView, self.collectionView.frame: %@", NSStringFromCGRect(self.collectionView.frame));
}

- (void) registerNib:(UINib *_Nonnull)nib forCellWithReuseIdentifier:(NSString *_Nonnull)identifier {
    self.horizontalCellIdentifier = identifier;
    self.horizontalItemCellNib = nib;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.horizontalCellIdentifier isEqualToString: @""] ? 0 : self.outbrainRecs.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView registerNib:self.horizontalItemCellNib forCellWithReuseIdentifier:self.horizontalCellIdentifier];
    SFCollectionViewCell *cell = (SFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier: self.horizontalCellIdentifier forIndexPath:indexPath];
    OBRecommendation *rec = self.outbrainRecs[indexPath.row];
    
    
    cell.recTitleLabel.textAlignment = [SFUtils isRTL:rec.content] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    cell.recSourceLabel.textAlignment = [SFUtils isRTL:rec.source] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
    if ([SFUtils isRTL:rec.content]) {
        [cell.contentView setNeedsDisplay];
        [cell.contentView setNeedsLayout];
    }
    
    cell.recTitleLabel.text = rec.content;
    if ([rec isPaidLink]) {
        cell.recSourceLabel.text = rec.source;
        if ([rec shouldDisplayDisclosureIcon]) {
            cell.adChoicesButton.hidden = NO;
            cell.adChoicesButton.imageEdgeInsets = UIEdgeInsetsMake(2.0, 12.0, 12.0, 2.0);
            cell.adChoicesButton.tag = indexPath.row;
            [[SFImageLoader sharedInstance] loadImage:rec.disclosure.imageUrl intoButton:cell.adChoicesButton];
            [cell.adChoicesButton addTarget:self action:@selector(adChoicesClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    else {
        cell.recSourceLabel.text = @"";
        if (rec.publisherLogoImage) {
            [[SFImageLoader sharedInstance] loadImage:rec.publisherLogoImage.url into:cell.publisherLogo];
            cell.publisherLogoWidth.constant = rec.publisherLogoImage.width;
            cell.publisherLogoHeight.constant = rec.publisherLogoImage.height;
        }
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:cell.recImageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OBRecommendation *rec = self.outbrainRecs[indexPath.row];
    cell.contentView.backgroundColor = UIColor.whiteColor;
    cell.contentView.layer.cornerRadius = 4.0f;
    cell.contentView.layer.borderWidth = 1.0f;
    cell.contentView.layer.borderColor = [UIColor clearColor].CGColor;
    cell.contentView.layer.masksToBounds = YES;
    
    cell.layer.shadowColor = rec.isPaidLink && (self.shadowColor != nil) ? self.shadowColor.CGColor : [UIColor lightGrayColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(0, 2.0f);
    cell.layer.shadowRadius = 2.0f;
    cell.layer.shadowOpacity = 1.0f;
    cell.layer.masksToBounds = NO;
    cell.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:cell.contentView.layer.cornerRadius].CGPath;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OBRecommendation *rec = self.outbrainRecs[indexPath.row];
    if (self.onRecommendationClick != nil) {
        self.onRecommendationClick(rec);
    }
}

-(void) setOutbrainRecs:(NSArray *)outbrainRecs {
    _outbrainRecs = outbrainRecs;
    if (self.outbrainRecs.count == 0) {
        return;
    }
    [self.collectionView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    });
}

- (void) adChoicesClicked:(id)sender {
    UIButton *adChoicesButton = sender;
    OBRecommendation *rec = self.outbrainRecs[adChoicesButton.tag];
    if (self.onAdChoicesIconClick != nil && rec != nil) {
        self.onAdChoicesIconClick(rec.disclosure.clickUrl);
    }
}

@end
