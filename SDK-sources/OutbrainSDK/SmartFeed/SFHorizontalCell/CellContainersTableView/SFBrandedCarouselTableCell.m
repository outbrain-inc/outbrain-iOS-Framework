//
//  SFBrandedCarouselTableCell.m
//  OutbrainSDK
//
//  Created by oded regev on 26/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "SFBrandedCarouselTableCell.h"
#import "SFUtils.h"


@implementation SFBrandedCarouselTableCell

-(void) setupDotsIndicator:(NSInteger) totalItems {
    for (UIView *v in self.horizontalPagerIndicatorStackView.arrangedSubviews) {
        [v removeFromSuperview];
    }
    for (int i=0; i <= totalItems; i++) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = UIColor.whiteColor;
        v.layer.borderWidth = 2.0;
        v.layer.borderColor = UIColorFromRGB(0x9b9b9b).CGColor;
        v.layer.cornerRadius = 5.0;

        v.tag = i;
        [v.heightAnchor constraintEqualToConstant:10].active = true;
        [v.widthAnchor constraintEqualToConstant:10].active = true;
        [self.horizontalPagerIndicatorStackView addArrangedSubview:v];
    }
}

-(void) setDotsIndicatorWithCurrentIndex:(NSInteger) currIndex {
    for (UIView *v in self.horizontalPagerIndicatorStackView.arrangedSubviews) {
        v.backgroundColor = (v.tag == currIndex) ? UIColor.blackColor : UIColor.whiteColor;
        v.layer.borderColor = (v.tag == currIndex) ? UIColor.blackColor.CGColor : UIColorFromRGB(0x9b9b9b).CGColor;
    }
}

@end
