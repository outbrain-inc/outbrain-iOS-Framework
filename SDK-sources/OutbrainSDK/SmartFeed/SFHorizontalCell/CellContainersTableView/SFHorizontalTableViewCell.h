//
//  SFHorizontalTableViewCell.h
//  SmartFeedLib
//
//  Created by oded regev on 29/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHorizontalView.h"
#import "SFHorizontalCollectionViewCell.h"

@interface SFHorizontalTableViewCell : UITableViewCell <SFHorizontalCellCommonProps>

@property (nonatomic, weak) IBOutlet SFHorizontalView *horizontalView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *publisherImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellTitleLeadingConstraint;

@end
