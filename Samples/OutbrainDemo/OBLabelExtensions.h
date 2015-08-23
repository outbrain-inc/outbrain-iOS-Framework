//
//  UILabel_OBLabelExtentions.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 5/8/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (OBLabelExtensions)
- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth;
@end

@implementation UILabel (OBLabelExtensions)


- (void)sizeToFitFixedWidth:(CGFloat)fixedWidth
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fixedWidth, 0);
    self.lineBreakMode = NSLineBreakByWordWrapping;
    self.numberOfLines = 0;
    [self sizeToFit];
}
@end