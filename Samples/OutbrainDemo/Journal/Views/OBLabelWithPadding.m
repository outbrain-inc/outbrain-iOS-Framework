//
//  OBLabelWithPadding.m
//  OutbrainDemo
//
//  Created by Oded Regev on 5/8/14.
//  Copyright (c) 2014 Outbrain inc. All rights reserved.
//

#import "OBLabelWithPadding.h"


@implementation OBLabelWithPadding

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end
