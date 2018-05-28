//
//  SFCollectionViewCell.m
//  SmartFeedLib
//
//  Created by oded regev on 22/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFCollectionViewCell.h"

@implementation SFCollectionViewCell

-(void) prepareForReuse {
    [super prepareForReuse];
    self.recImageView.image = nil;
    self.recTitleLabel.text = nil;
    self.recSourceLabel.text = nil;
    self.adChoicesButton.hidden = YES;
}

@end
