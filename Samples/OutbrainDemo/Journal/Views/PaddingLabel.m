//
//  PaddingLabel.m
//  Journal
//
//  Created by oded regev on 11/1/17.
//  Copyright (c) 2017 Outbrain. All rights reserved.
//

#import "PaddingLabel.h"

@implementation PaddingLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10.0, 0, 10.0};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
@end
