//
//  SFHorizontalCell.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalCell.h"
#import "SFUtils.h"

@implementation SFHorizontalCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.horizontalView = [[SFHorizontalView alloc] initWithFrame:self.frame];
        [self.contentView addSubview:self.horizontalView];
        [SFUtils addConstraintsToFillParent:self.horizontalView];
    }
    return self;
}

@end
