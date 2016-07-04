//
//  ArticlesListVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/31/13.
//  Copyright (c) 2013 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBRecommendationSlideCell.h"
@import SafariServices;

@class PostsSwipeVC;

@interface PostsListVC : UITableViewController <OBWidgetViewDelegate, SFSafariViewControllerDelegate>

@property (nonatomic, strong) PostsSwipeVC * detailVC;

@property (nonatomic, strong) NSMutableArray * postsData;

@end
