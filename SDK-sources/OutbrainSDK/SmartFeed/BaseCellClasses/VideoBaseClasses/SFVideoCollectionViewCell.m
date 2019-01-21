//
//  SFVideoCollectionViewCell.m
//  OutbrainSDK
//
//  Created by oded regev on 12/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFVideoCollectionViewCell.h"
#import "SFItemData.h"

@interface SFVideoCollectionViewCell() 

@property (nonatomic, strong) SFScriptMessageHandler *wkScriptMessageHandler;

@end

@implementation SFVideoCollectionViewCell

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.wkScriptMessageHandler = [[SFScriptMessageHandler alloc] initWithSFVideoCell:self];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.recImageView.image = nil;
    self.recTitleLabel.text = nil;
    self.recSourceLabel.text = nil;
    self.cellTitleLabel.text = nil;
}

@end
