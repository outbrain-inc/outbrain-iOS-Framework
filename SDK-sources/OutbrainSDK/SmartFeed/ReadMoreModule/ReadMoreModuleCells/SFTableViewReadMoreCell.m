//
//  SFTableViewReadMoreCell.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 23/11/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import "SFTableViewReadMoreCell.h"
#import "SFUtils.h"

@implementation SFTableViewReadMoreCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.readMoreLabel.layer.borderWidth = 1.0;
    self.readMoreLabel.layer.borderColor = UIColorFromRGB(0x4a90e2).CGColor;
    self.readMoreLabel.layer.cornerRadius = 3.0;
}

@end
