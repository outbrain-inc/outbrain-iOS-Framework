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

@interface TopBoxPostViewCell : UICollectionViewCell  <UIScrollViewDelegate, OBWidgetViewDelegate> {
    IBOutlet UIScrollView   *mainScrollView;
    IBOutlet UILabel        *textView;
}

@property (nonatomic, strong) IBOutlet OBTopBoxView *topBoxView;
@property (nonatomic, strong) IBOutlet UIScrollView   *mainScrollView;
@property (nonatomic, strong) IBOutlet UILabel        *textView;

@property (nonatomic, weak) Post * post;

/**
 *  Used when this cell has completely moved into view
 **/
- (void)delayedContentLoad;


@end
