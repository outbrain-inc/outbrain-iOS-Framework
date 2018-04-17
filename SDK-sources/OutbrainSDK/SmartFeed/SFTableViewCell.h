//
//  SFTableViewCell.h
//  SmartFeedLib
//
//  Created by oded regev on 29/03/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SFTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *recImageView;
@property (nonatomic, weak) IBOutlet UILabel *recTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *recSourceLabel;


@end
