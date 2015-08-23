//
//  OBWebVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/17/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OBRecommendation;

@interface OBRecommendationWebVC : UIViewController <UIWebViewDelegate>

@property (nonatomic, weak, readonly) IBOutlet UIWebView * webView;


/**
 *  Discussion:
 *      Setting this will register the click and visit the url.
 **/
@property (nonatomic, strong) OBRecommendation * recommendation;

@end
