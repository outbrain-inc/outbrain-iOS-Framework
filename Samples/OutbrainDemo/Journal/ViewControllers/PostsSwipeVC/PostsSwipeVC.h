//
//  PostsSwipeVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/2/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>
@import SafariServices;

// Determines how frequent we want to show interstitials
#define INTERSTITIAL_FREQUENCY  4


@class OBParalaxTitleView;
@class Post;

@interface PostsSwipeVC : UICollectionViewController <UICollectionViewDelegateFlowLayout, SFSafariViewControllerDelegate>

/**
 *  Discussion:
 *      This will do some fancy animations while changing articles.
 **/
@property (nonatomic, weak) IBOutlet OBParalaxTitleView * titleView;


/**
 *  Give the current Posts and the currentIndex chosen.
 **/
@property (nonatomic, strong) NSArray * posts;
@property (nonatomic, assign) NSInteger currentIndex;

@end
