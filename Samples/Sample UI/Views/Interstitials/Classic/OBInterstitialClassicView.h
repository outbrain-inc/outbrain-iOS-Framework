//
//  OBInterstitialClassicView.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/28/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBInterstitialViewProtocol.h"

/**
 *  Discussion:
 *      This interstitial is meant to be a full-screen view.  This view also has the ability to present as a viewController
 **/

@interface OBInterstitialClassicView : UIView <OBInterstitialViewProtocol>
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



/**
 *  Discussion:
 *      This is where we attempt to fetch the images.  If you want to fetch images yourself then override this method
 **/
- (void)fetchImageForURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;


@end


@interface OBInterstitialClassicVC : UIViewController
@property (nonatomic, weak, readonly) OBInterstitialClassicView * classicView;
@end