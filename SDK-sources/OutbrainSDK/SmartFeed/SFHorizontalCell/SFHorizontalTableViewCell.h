//
//  SFHorizontalTableViewCell.h
//  SmartFeedLib
//
//  Created by oded regev on 29/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SFHorizontalView.h"

@interface SFHorizontalTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet SFHorizontalView *horizontalView;
@property (nonatomic, weak) IBOutlet UILabel *moreFromLabel;
@property (nonatomic, weak) IBOutlet UIImageView *moreFromImageView;

@end
