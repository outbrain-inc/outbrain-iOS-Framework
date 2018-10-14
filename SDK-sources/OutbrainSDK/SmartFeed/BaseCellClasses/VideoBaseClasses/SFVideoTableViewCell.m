//
//  SFVideoTableViewCell.m
//  OutbrainSDK
//
//  Created by oded regev on 25/09/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFVideoTableViewCell.h"
#import "SFItemData.h"

@interface SFVideoTableViewCell()

@property (nonatomic, strong) SFScriptMessageHandler *wkScriptMessageHandler;

@end

@implementation SFVideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.wkScriptMessageHandler = [[SFScriptMessageHandler alloc] initWithSFVideoCell:self];
    }
    return self;
}


@end
