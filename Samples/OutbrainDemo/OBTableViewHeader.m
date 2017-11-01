//
//  OBTableViewHeader.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/28/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBTableViewHeader.h"

#define OBDarkOrange [UIColor colorWithRed:185/255.0 green:96/255.0 blue:0 alpha:1.000]
#define OBOrange [UIColor colorWithRed:0.914 green:0.506 blue:0.129 alpha:1.000];

#define TRIANGLE_SIDE 15
#define LABEL_LEFT_PADDING 10
#define LABEL_TOP_PADDING 5
#define LEFT_RIGHT_CELL_MARGIN 10

@interface OBTableViewHeader ()
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *brandingImageButton;

@end


@implementation OBTableViewHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,20)];
        self.headerLabel.text = @"Also on the Web";
        self.headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0];
        [self.headerLabel sizeToFit];
        self.headerLabel.frame = CGRectMake(self.headerLabel.frame.origin.x, self.headerLabel.frame.origin.y, self.headerLabel.frame.size.width + LABEL_LEFT_PADDING * 2, self.headerLabel.frame.size.height + LABEL_TOP_PADDING*2);
        self.headerLabel.textAlignment = NSTextAlignmentCenter;
        self.headerLabel.backgroundColor = OBOrange;
        self.headerLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.headerLabel];
        
        self.brandingImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.brandingImageButton addTarget:delegate action:@selector(brandingDidClick) forControlEvents:UIControlEventTouchUpInside];
        [self.brandingImageButton setImage:[UIImage imageNamed:@"logo"] forState:UIControlStateNormal];
        CGRect r = CGRectMake(0, 0, 71, 18);
        r.origin.y = self.ameliaHeaderHeight;
        r.origin.x = (self.frame.size.width - r.size.width - 5.f - LEFT_RIGHT_CELL_MARGIN);
        self.brandingImageButton.frame = r;
        [self addSubview:self.brandingImageButton];

    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    float bottomLabel = CGRectGetMaxY(self.headerLabel.frame);
    [path moveToPoint:CGPointMake(0, bottomLabel)];
    [path addLineToPoint:CGPointMake(TRIANGLE_SIDE, bottomLabel + 2*TRIANGLE_SIDE/3)];
    [path addLineToPoint:CGPointMake(TRIANGLE_SIDE, bottomLabel)];
    [path closePath];
    [OBDarkOrange set];
    [path fill];
}

@end
