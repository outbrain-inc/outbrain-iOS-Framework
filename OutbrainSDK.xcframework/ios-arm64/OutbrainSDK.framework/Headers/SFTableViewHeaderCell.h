//
//  SFTableViewHeaderCell.h
//  OutbrainSDK
//
//  Created by oded regev on 20/08/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBLabel;

@interface SFTableViewHeaderCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *headerLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *adChoicesImageView;


@end
