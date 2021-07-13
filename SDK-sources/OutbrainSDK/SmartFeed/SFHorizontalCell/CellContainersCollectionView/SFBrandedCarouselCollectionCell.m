//
//  SFBrandedCarouselCollectionCell.m
//  OutbrainSDK
//
//  Created by oded regev on 18/05/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "SFBrandedCarouselCollectionCell.h"
#import "SFUtils.h"


@implementation SFBrandedCarouselCollectionCell

static UIColor *SelectedColor;
static UIColor *NonSelectedColor;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        SelectedColor = [[SFUtils sharedInstance] darkMode] ? UIColor.whiteColor : UIColor.blackColor;
        NonSelectedColor = [[SFUtils sharedInstance] darkMode] ? UIColorFromRGB(0x777777) : UIColorFromRGB(0xcccccc);
    }
    return self;
}
-(void) setupDotsIndicator:(NSInteger) totalItems {
    for (UIView *v in self.horizontalPagerIndicatorStackView.arrangedSubviews) {
        [v removeFromSuperview];
    }
    for (int i=0; i <= totalItems; i++) {
        UIView *v = [[UIView alloc] init];
        v.backgroundColor = NonSelectedColor;
        v.layer.cornerRadius = 4.0;
        
        v.tag = i;
        [v.heightAnchor constraintEqualToConstant:8].active = true;
        [v.widthAnchor constraintEqualToConstant:8].active = true;
        [self.horizontalPagerIndicatorStackView addArrangedSubview:v];
    }
}

-(void) setDotsIndicatorWithCurrentIndex:(NSInteger) currIndex {
    for (UIView *v in self.horizontalPagerIndicatorStackView.arrangedSubviews) {
        v.backgroundColor = (v.tag == currIndex) ? SelectedColor : NonSelectedColor;
    }
}


@end
