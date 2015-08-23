//
//  OBOBIPadInterstitialClassicView.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/7/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBInterstitialViewProtocol.h"
#import "OBWidgetViewProtocol.h"

@protocol OBIPadInterstitialHeaderDelegate <NSObject>
- (void)brandingDidClick;
@end

/**
 *  Discussion:
 *      This interstitial is meant to be a full-screen view.  This view also has the ability to present as a viewController
 **/

@interface OBIPadInterstitialClassicView : UIView <OBIPadInterstitialHeaderDelegate, OBWidgetViewProtocol>
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
@property (nonatomic, weak) id <OBWidgetViewDelegate> widgetDelegate;

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


@interface OBIPadInterstitialClassicVC : UIViewController
@property (nonatomic, weak, readonly) OBIPadInterstitialClassicView * classicView;
@end