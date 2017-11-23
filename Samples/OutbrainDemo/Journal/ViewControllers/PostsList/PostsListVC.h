//
//  PostsListVC.h
//  OutbrainDemo
//
//  Created by Oded Regev on 11/1/17.
//  Copyright (c) 2017 Outbrain inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecommendationSlideCell.h"
@import SafariServices;

@class PostsSwipeVC;

@interface PostsListVC : UITableViewController <OBWidgetViewDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong) PostsSwipeVC * detailVC;

@property (nonatomic, strong) NSMutableArray * postsData;

@end
