//
//  SFHorizontalCollectionViewCell.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHorizontalView.h"

@protocol SFHorizontalCellCommonProps
@required
// list of required methods
@property (nonatomic, weak) IBOutlet SFHorizontalView *horizontalView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalViewLeadingConstraint;

- (BOOL)respondsToSelector:(SEL)aSelector;

@optional

@property (nonatomic, weak) IBOutlet UIView *cellView;
@end


@interface SFHorizontalCollectionViewCell : UICollectionViewCell <SFHorizontalCellCommonProps>

@property (nonatomic, weak) IBOutlet SFHorizontalView *horizontalView;
@property (nonatomic, weak) IBOutlet UIView *cellView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *publisherImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalViewTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *horizontalViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellTitleLeadingConstraint;

@end
