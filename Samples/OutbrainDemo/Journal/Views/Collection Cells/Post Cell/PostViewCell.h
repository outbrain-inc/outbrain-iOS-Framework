//
//  PostVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBClassicRecommendationsView.h"
#import "OBAdhesionView.h"

@class Post;

/**
 *  This class represents a single post
 **/

@interface PostViewCell : UICollectionViewCell <UIScrollViewDelegate>

@property (nonatomic, weak) Post * post;

/**
 *  Using UIWebView for ios6. 
 **/
//@property (nonatomic, weak) IBOutlet UIWebView * webView;
@property (nonatomic, weak) IBOutlet UITextView * textView;


/**
 *  This is our `hover` view that will hover over our content
 **/
@property (nonatomic, strong) OBAdhesionView * outbrainHoverView;

/**
 *  This is our recommendation view that we'll show at the end
 *  of the webview content
 **/
@property (nonatomic, strong) OBClassicRecommendationsView * outbrainClassicView;


/**
 *  The height we want our outbrain recommendations view to be.
 *  Defaults: 200.f
 **/
@property (nonatomic, assign) CGFloat outbrainViewHeight;

/**
 *  Used when this cell has completely moved into view
 **/
- (void)delayedContentLoad;

@end
