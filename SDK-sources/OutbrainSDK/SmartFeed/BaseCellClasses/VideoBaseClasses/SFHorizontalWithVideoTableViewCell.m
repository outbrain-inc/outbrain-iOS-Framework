//
//  SFHorizontalWithVideoTableViewCell.m
//  OutbrainSDK
//
//  Created by oded regev on 14/10/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalWithVideoTableViewCell.h"
#import "SFUtils.h"

@interface SFHorizontalWithVideoTableViewCell()

@property (nonatomic, strong) SFScriptMessageHandler *wkScriptMessageHandler;

@end


@implementation SFHorizontalWithVideoTableViewCell

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.wkScriptMessageHandler = [[SFScriptMessageHandler alloc] initWithSFVideoCell:self];
    }
    return self;
}

@end
