//
//  MainPostViewCell.m
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 12/24/14.
//  Copyright (c) 2014 Outbrain inc. All rights reserved.
//

#import "MainPostViewCell.h"

#define TITLE_LEFT_PADDING 10
#define TITLE_TOP_PADDING 10
#define IMAGE_VIEW_SIZE 40

@implementation MainPostViewCell
@synthesize titleLabel;
@synthesize subtitleLabel;
@synthesize imageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(TITLE_TOP_PADDING, TITLE_LEFT_PADDING, IMAGE_VIEW_SIZE, IMAGE_VIEW_SIZE)];
        [self.contentView addSubview:imageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + TITLE_LEFT_PADDING, TITLE_TOP_PADDING, 320 - imageView.frame.size.width - 3*TITLE_LEFT_PADDING, 16)];
        titleLabel.numberOfLines = 1;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13.0f];
        [self.contentView addSubview:titleLabel];

        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + TITLE_LEFT_PADDING, CGRectGetMaxY(self.titleLabel.frame), 320 - imageView.frame.size.width - 3*TITLE_LEFT_PADDING, 50)];
        subtitleLabel.numberOfLines = 3;
        subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0f];
        subtitleLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:subtitleLabel];
    }
    return self;
}

- (void)prepareForReuse {
    self.imageView.image = nil;
    [super prepareForReuse];
}

@end
