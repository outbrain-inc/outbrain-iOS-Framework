//
//  SFBrandedCarouselTableCell.h
//  OutbrainSDK
//
//  Created by oded regev on 26/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//


#import "SFHorizontalTableViewCell.h"

@interface SFBrandedCarouselTableCell : SFHorizontalTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleSponsoredByLabel;
@property (nonatomic, weak) IBOutlet UILabel *titleSourceLabel;
@property (nonatomic, weak) IBOutlet UIImageView *cellBrandLogoImageView;
@property (nonatomic, weak) IBOutlet UIStackView *horizontalPagerIndicatorStackView;

-(void) setupDotsIndicator:(NSInteger) totalItems;

-(void) setDotsIndicatorWithCurrentIndex:(NSInteger) currIndex;

@end



