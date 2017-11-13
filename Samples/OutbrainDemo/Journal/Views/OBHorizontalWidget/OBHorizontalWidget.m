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
#import <OutbrainSDK/OutbrainSDK.h>
#import <QuartzCore/QuartzCore.h>


@interface OBHorizontalWidget()

@property (strong, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *outbrainBrandingView;
@property (weak, nonatomic) IBOutlet OBLabel *recommendedByLabel;


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
        
        // Add bottom border
        CALayer *bottomBorder = [CALayer layer];
        bottomBorder.frame = CGRectMake(0.0f, self.frame.size.height - 1.0, self.frame.size.width, 1.0f);
        bottomBorder.backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
        [self.layer addSublayer:bottomBorder];
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

#pragma mark - Viewability
- (void) setUrl:(NSString *)url andWidgetId:(NSString *)widgetId {
    [Outbrain registerOBLabel:self.recommendedByLabel withWidgetId:widgetId andUrl:url];
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
    
    cell.recImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.recImageView.layer.borderWidth = 1.0f;
    cell.recImageView.image = nil;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    spinner.color = UIColor.grayColor;
    spinner.center = cell.recImageView.center;
    [spinner startAnimating];
    [cell addSubview:spinner];
    
    
    [OBDemoDataHelper fetchImageWithURL:rec.image.url withCallback:^(UIImage *image) {
        cell.recImageView.image = image;
        [spinner removeFromSuperview];
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
