//
//  OBInterstitialHeroGridView.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/29/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OutbrainSDK/OutbrainSDK.h>
#import "OBInterstitialViewProtocol.h"

/**
 *  Discussion:
 *      This is a full page widget.  This has a full width (hero) cell at the top, followed by 
 *      2 boxes on each side for the rest.   It also has pull-to-load-more from the bottom.
 **/

@interface OBInterstitialHeroGridView : UIView <OBInterstitialViewProtocol>
/** @name Callbacks **/

/**
 *  Discussion:
 *      Handler for when the widget detects that the user tapped on a recommendation.
 *
 *  @note:  You can optionally use the `widgetDelegate` instead
 **/
@property (nonatomic, copy) OBWRecommendationTappedHandler recommendationTapHandler;

/**
 *  Discussion:
 *      Delegate style handler for those who don't like using the block style handlers.
 *
 **/
@property (nonatomic, weak) id <OBInterstitialViewDelegate> widgetDelegate;

/**
 *  Discussion:
 *      The request for the interstitial.  We will use this request to handle loading more responses.
 **/
@property (nonatomic, strong) OBRequest * request;

/**
 *  Discussion:
 *      Since the interstitial view is handling the network requests for you, then you may supply
 *      the loading view to show/hide while the request is being made.
 **/
@property (nonatomic, strong) UIView * loadingView;



@end



/**
 *  Discussion:
 *      You can optionally use this if you'd like to use a modal, or maybe UIPageViewController.
 **/

@interface OBInterstitialHeroGridVC : UIViewController
@property (nonatomic, weak, readonly) OBInterstitialHeroGridView * interstitialView;
@end
