//
//  SFHorizontalWithVideoCollectionViewCell.m
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import "SFHorizontalWithVideoCollectionViewCell.h"
#import "SFUtils.h"

@interface SFHorizontalWithVideoCollectionViewCell()

@property (nonatomic, strong) SFScriptMessageHandler *wkScriptMessageHandler;

@end


@implementation SFHorizontalWithVideoCollectionViewCell

-(instancetype) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.wkScriptMessageHandler = [[SFScriptMessageHandler alloc] initWithSFVideoCell:self];
    }
    return self;
}

@end
