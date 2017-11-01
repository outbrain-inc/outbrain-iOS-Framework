//
//  TopBoxPostViewCell.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 3/1/15.
//  Copyright (c) 2015 Mercury Intermedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Post.h"
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBTopBoxView.h"

@interface TopBoxPostViewCell : UICollectionViewCell  <UIScrollViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *topPaddingView;
@property (weak, nonatomic) IBOutlet UILabel *postTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *postDateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *postImageView;
@property (weak, nonatomic) IBOutlet UITextView *postContentTextView;

@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet OBTopBoxView *topBoxView;


@property (nonatomic, weak) Post * post;

/**
 *  Used when this cell has completely moved into view
 **/
- (void)delayedContentLoad;


@end
