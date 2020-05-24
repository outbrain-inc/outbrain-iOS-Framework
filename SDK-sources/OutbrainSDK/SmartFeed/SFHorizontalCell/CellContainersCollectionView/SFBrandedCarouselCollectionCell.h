//
//  SFBrandedCarouselCollectionCell.h
//  OutbrainSDK
//
//  Created by oded regev on 18/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <OutbrainSDK/OutbrainSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface SFBrandedCarouselCollectionCell : SFHorizontalCollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleSponsoredByLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleSourceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *cellBrandLogoImageView;
@property (nonatomic, weak) IBOutlet UIStackView *horizontalPagerIndicatorStackView;

-(void) setupDotsIndicator:(NSInteger) totalItems;

-(void) setDotsIndicatorWithCurrentIndex:(NSInteger) currIndex;

@end

NS_ASSUME_NONNULL_END
