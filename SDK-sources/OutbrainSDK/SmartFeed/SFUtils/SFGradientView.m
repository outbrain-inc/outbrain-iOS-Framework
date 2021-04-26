//
//  SFGradientView.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 7/27/20.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "SFGradientView.h"

@interface SFGradientView()

@property (nonatomic, assign) BOOL isConfigured;

@end

IB_DESIGNABLE
@implementation SFGradientView

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!self.isConfigured) {
        [self configure];
    }
}

- (void)configure {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    
    gradient.frame = self.bounds;
    
    gradient.colors =  @[(id)[UIColor clearColor].CGColor, (id)[UIColor colorWithWhite:0 alpha:0.7].CGColor];

    [self.layer insertSublayer:gradient atIndex:0];
    self.isConfigured = YES;
}

@end
