//
//  OBHorizontalWidgetCell.h
//  Journal
//
//  Created by oded regev on 11/5/17.
//  Copyright © 2017 Outbrain inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OBHorizontalWidgetCell : UICollectionViewCell


@property (weak, nonatomic) IBOutlet UIImageView *recImageView;

@property (weak, nonatomic) IBOutlet UILabel *recTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *recSourceLabel;



@end
