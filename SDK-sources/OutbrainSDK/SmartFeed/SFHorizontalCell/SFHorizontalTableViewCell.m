//
//  SFHorizontalTableViewCell.m
//  SmartFeedLib
//
//  Created by oded regev on 29/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalTableViewCell.h"
#import "SFUtils.h"

@implementation SFHorizontalTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.horizontalView = [[SFHorizontalView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 250)];
        [self.contentView addSubview:self.horizontalView];
        self.contentView.backgroundColor = UIColor.blueColor;
        [SFUtils addConstraintsToFillParent:self.horizontalView];
        [SFUtils addHeightConstraint:250.0 toView:self.horizontalView];
    }
    return self;
}

@end
