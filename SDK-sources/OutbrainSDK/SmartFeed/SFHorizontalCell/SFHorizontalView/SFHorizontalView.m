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
    cell.recTitleLabel.text = rec.content;
    if ([rec isPaidLink]) {
        cell.recSourceLabel.text = rec.source;
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
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    });
}

@end
