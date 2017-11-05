//
//  OBHorizontalWidget.m
//  Journal
//
//  Created by oded regev on 11/5/17.
//  Copyright © 2017 Outbrain inc. All rights reserved.
//

#import "OBHorizontalWidget.h"
#import "OBHorizontalWidgetCell.h"
#import "OBDemoDataHelper.h"
#import <OutbrainSDK/OBRecommendationResponse.h>

@interface OBHorizontalWidget()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *outbrainBrandingView;


@end

@implementation OBHorizontalWidget

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self addSubview:
         [[[NSBundle mainBundle] loadNibNamed:@"OBHorizontalWidget"
                                        owner:self
                                      options:nil] objectAtIndex:0]];
        
        [self.collectionView
         registerNib: [UINib nibWithNibName:@"OBHorizontalWidgetCell" bundle:[NSBundle mainBundle]]
         forCellWithReuseIdentifier: @"OBHorizontalWidgetCell"];
        
        self.contentView.frame = self.bounds;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(brandingTapAction:)];
        [self.outbrainBrandingView addGestureRecognizer:singleFingerTap];
    }
    return self;
}



#pragma - mark Set Recommendations
- (void)setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse
{
    if ([self.recommendationResponse isEqual:recommendationResponse]) {
        return;
    }
    
    _recommendationResponse = recommendationResponse;
    
    [self.collectionView reloadData];
}

#pragma - IBActions
- (void)brandingTapAction:(id)sender
{
    if (self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetViewTappedBranding:)])
    {
        [self.widgetDelegate widgetViewTappedBranding:self];
    }
}

#pragma - mark UICollectionView Data Source
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommendationResponse != nil ? [self.recommendationResponse.recommendations count] : 0;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"OBHorizontalWidgetCell";
    
    OBHorizontalWidgetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    OBRecommendation *rec = self.recommendationResponse.recommendations[indexPath.row];
    
    cell.recTitleLabel.text = rec.content;
    cell.recSourceLabel.text = [NSString stringWithFormat:@"(%@)", (rec.source ? rec.source : rec.author)];
    
    // First check if there's an image
    cell.recImageView.hidden = (rec.image == nil);
    
    [OBDemoDataHelper fetchImageWithURL:rec.image.url withCallback:^(UIImage *image) {
        cell.recImageView.image = image;
        if ([rec isPaidLink]) {
            [Outbrain prepare: cell.recImageView withRTB: rec onClickBlock:^(NSURL *url) {
                NSLog(@"OBHorizontalWidget --> click url: %@", url.absoluteString);
                [[UIApplication sharedApplication] openURL: url];
            }];
        }
    }];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(CGRectGetWidth(collectionView.bounds), (CGRectGetHeight(collectionView.bounds)));
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    OBRecommendation *rec = self.recommendationResponse.recommendations[indexPath.row];
    if (self.widgetDelegate && [self.widgetDelegate respondsToSelector:@selector(widgetView:tappedRecommendation:)])
    {
        [self.widgetDelegate widgetView:self tappedRecommendation:rec];
    }
}

@end
