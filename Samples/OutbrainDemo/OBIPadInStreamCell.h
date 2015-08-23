//
//  OBIPadInStreamCell.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 5/8/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBLabelWithPadding.h"

@interface OBIPadInStreamCell : UICollectionViewCell {
    UIImageView           *imageView;
    OBLabelWithPadding    *categoryLabel;
    UILabel               *titleLabel;
}

@property (nonatomic, strong) UIImageView           *imageView;
@property (nonatomic, strong) OBLabelWithPadding    *categoryLabel;
@property (nonatomic, strong) UILabel               *titleLabel;

@end
