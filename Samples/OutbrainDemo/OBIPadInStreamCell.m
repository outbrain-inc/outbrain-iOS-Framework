//
//  OBIPadInStreamCell.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 5/8/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBIPadInStreamCell.h"
#import "OBLabelExtensions.h"

#define IMAGE_VIEW_HEIGHT 140.0f
#define CATEGORY_LABEL_WIDTH 150.0f
#define CATEGORY_LABEL_HEIGHT 25.0f
#define CATEGORY_LABEL_TOP_BOTTOM_PADDING 10.0f
#define CATEGORY_LABEL_LEFT_PADDING 5.0f
#define SIDE_PADDING 10.0f
#define IMAGE_VIEW_TITLE_LABEL_PADDING 10.0f
#define TITLE_LABEL_HEIGHT 80.0f

@interface OBIPadInStreamCell ()
@end

@implementation OBIPadInStreamCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

#define ARC4RANDOM_MAX      0x100000000

- (void)commonInit {
    self.backgroundColor = [UIColor whiteColor];
    imageView = [[UIImageView alloc] init];
    categoryLabel = [[OBLabelWithPadding alloc] init];
    titleLabel = [[UILabel alloc] init];
    titleLabel.numberOfLines = 3;
    categoryLabel.numberOfLines = 1;
    categoryLabel.textColor = [UIColor whiteColor];
    categoryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];

    [self applyLayout];

    [self addSubview:imageView];
    [self addSubview:categoryLabel];
    [self addSubview:titleLabel];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    float darknessFactor = -0.15f;
    double r = ((double)arc4random() / ARC4RANDOM_MAX) + darknessFactor;
    double g = ((double)arc4random() / ARC4RANDOM_MAX) + darknessFactor;
    double b = ((double)arc4random() / ARC4RANDOM_MAX) + darknessFactor;

    categoryLabel.backgroundColor = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    categoryLabel.edgeInsets = UIEdgeInsetsMake(CATEGORY_LABEL_TOP_BOTTOM_PADDING, CATEGORY_LABEL_LEFT_PADDING, CATEGORY_LABEL_TOP_BOTTOM_PADDING, 0);
}

- (void)applyLayout {
    imageView.frame = CGRectMake(SIDE_PADDING, SIDE_PADDING, self.frame.size.width - 2*SIDE_PADDING, IMAGE_VIEW_HEIGHT);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

    categoryLabel.frame = CGRectMake(CGRectGetMaxX(imageView.frame) - CATEGORY_LABEL_WIDTH, CGRectGetMaxY(imageView.frame) - CATEGORY_LABEL_HEIGHT/2, CATEGORY_LABEL_WIDTH, CATEGORY_LABEL_HEIGHT);
    
    titleLabel.frame = CGRectMake(SIDE_PADDING, CGRectGetMaxY(categoryLabel.frame) + IMAGE_VIEW_TITLE_LABEL_PADDING, self.contentView.frame.size.width - 2*SIDE_PADDING, TITLE_LABEL_HEIGHT);
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self applyLayout];
}

@end
