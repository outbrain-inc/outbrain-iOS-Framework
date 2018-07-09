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
#import "PageCollectionLayout.h"
#import "SFCollectionViewCell.h"
#import "SFImageLoader.h"

@interface SFHorizontalView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, copy) NSString *horizontalCellIdentifier;
@property (nonatomic, strong) UINib *horizontalItemCellNib;

@property (nonatomic, assign) BOOL didInitCollectionViewLayout;
@property (nonatomic, assign) CGSize itemSize;

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
    UICollectionViewLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self.didInitCollectionViewLayout = YES;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = UIColor.whiteColor;
    [self.collectionView registerNib:self.horizontalItemCellNib forCellWithReuseIdentifier:self.horizontalCellIdentifier];
    [self addSubview:self.collectionView];
    
    [SFUtils addConstraintsToFillParent:self.collectionView];
    [self setNeedsLayout];
    
    // NSLog(@"SFHorizontalView - setupView, self.collectionView.frame: %@", NSStringFromCGRect(self.collectionView.frame));
    const CGFloat itemWidth = MAX(self.collectionView.frame.size.width*0.6, 250.0);
    const CGFloat itemHeight = MIN(itemWidth*0.7, self.collectionView.frame.size.height);
    self.itemSize = CGSizeMake(itemWidth, itemHeight);
    [self resetLayout:self.itemSize];
}

-(void) resetLayout:(CGSize) itemSize {
    self.itemSize = itemSize;
    UICollectionViewFlowLayout *layout = [[PageCollectionLayout alloc] initWithItemSize:self.itemSize];
    self.collectionView.collectionViewLayout = layout;
    [self.collectionView.collectionViewLayout invalidateLayout];
    // NSLog(@"resetLayout - self.itemSize: width: %f, height: %f", self.itemSize.width, self.itemSize.height);
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
    SFCollectionViewCell *cell = (SFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier: self.horizontalCellIdentifier forIndexPath:indexPath];
    OBRecommendation *rec = self.outbrainRecs[indexPath.row];
    cell.recTitleLabel.text = rec.content;
    if ([rec isPaidLink]) {
        cell.recSourceLabel.text = [NSString stringWithFormat:@"Sponsored | %@", rec.source];
    }
    else {
        cell.recSourceLabel.text = rec.source;
    }
    
    [[SFImageLoader sharedInstance] loadImage:rec.image.url into:cell.recImageView];
    
    return cell;
}

-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    OBRecommendation *rec = self.outbrainRecs[indexPath.row];
    if (self.onClick != nil) {
        self.onClick(rec);
    }
}

-(void) setOutbrainRecs:(NSArray *)outbrainRecs {
    _outbrainRecs = outbrainRecs;
    [self.collectionView reloadData];
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

@end
