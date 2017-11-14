//
//  OBHorizontalWidgetCell.m
//  Journal
//
//  Created by oded regev on 11/5/17.
//  Copyright © 2017 Outbrain inc. All rights reserved.
//

#import "OBHorizontalWidgetCell.h"

@implementation OBHorizontalWidgetCell

-(void) prepareForReuse {
    // Remove disclosure icon if exists
    NSArray *viewsToRemove = [self.recImageView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
}

@end
