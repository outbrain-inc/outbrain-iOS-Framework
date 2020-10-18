//
//  MainPostViewCell.h
//  OutbrainDemo
//
//  Created by Oded Regev on 12/24/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainPostViewCell : UITableViewCell {
    UILabel             *titleLabel;
    UILabel             *subtitleLabel;
    UIImageView         *imageView;
}

@property (nonatomic, strong) UILabel             *titleLabel;
@property (nonatomic, strong) UILabel             *subtitleLabel;
@property (nonatomic, strong) UIImageView         *imageView;

@end
