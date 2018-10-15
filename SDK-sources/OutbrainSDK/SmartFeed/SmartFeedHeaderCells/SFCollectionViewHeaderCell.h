//
//  SFCollectionViewHeaderCell.h
//  OutbrainSDK
//
//  Created by oded regev on 20/08/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBLabel;

@interface SFCollectionViewHeaderCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet OBLabel *headerOBLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *adChoicesImageView;

@end
