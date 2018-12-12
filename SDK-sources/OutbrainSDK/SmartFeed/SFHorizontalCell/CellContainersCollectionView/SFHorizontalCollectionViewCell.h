//
//  SFHorizontalCollectionViewCell.h
//  SmartFeedLib
//
//  Created by oded regev on 12/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHorizontalView.h"

@interface SFHorizontalCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet SFHorizontalView *horizontalView;
@property (nonatomic, weak) IBOutlet UIView *cellView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *publisherImageView;

@end
