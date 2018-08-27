//
//  SFTableViewCell.m
//  SmartFeedLib
//
//  Created by oded regev on 29/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFTableViewCell.h"

@implementation SFTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) prepareForReuse {
    [super prepareForReuse];
    self.publisherLogo.image = nil;
    self.recImageView.image = nil;
    self.recTitleLabel.text = nil;
    self.recSourceLabel.text = nil;
    self.adChoicesButton.hidden = YES;
    self.outbrainLabelingContainer.hidden = YES;
}

@end
