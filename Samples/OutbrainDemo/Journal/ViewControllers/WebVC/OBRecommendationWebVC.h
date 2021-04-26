//
//  OBWebVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/17/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
@import WebKit;


@class OBRecommendation;

@interface OBRecommendationWebVC : UIViewController <UIWebViewDelegate, WKNavigationDelegate>

- (void) loadURL:(NSURL *)url;

/**
 *  Discussion:
 *      Setting this will register the click and visit the url.
 **/
@property (nonatomic, strong) NSURL * recommendationUrl;

@end
