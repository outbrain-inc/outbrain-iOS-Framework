//
//  OBInterstitialViewProtocol.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/7/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBRequest;
@class OBRecommendation;

@protocol OBInterstitialViewProtocol;


// Callback defines
typedef void(^OBWRecommendationTappedHandler)(OBRecommendation * recommendation);

@protocol OBInterstitialViewDelegate <NSObject>
- (void)widgetViewDidLoadRecommendations:(id<OBInterstitialViewProtocol>)widgetView;
- (void)widgetView:(id<OBInterstitialViewProtocol>)widgetView tappedRecommendation:(OBRecommendation *)recommendation;
@end


/**
 *  This is an advanced configuration helper for creating your own Outbrain Recommendations UI's.
 *  Below is a protocol that your UI Widget should conform to.  We've also included a helper macro
 *  for adhering to the protocol without having to copy and paste everything.
 *
 *  Example:
 *
 *  // MyCustomWidget.h
 *  #import "OBWidgetViewProtocol.h"
 *
 *  @interface MyCustomWidgetView : UIControl <OBWidgetViewProtocol>        <-- Says `MyCustomWidgetView` should conform to the `OBWidgetViewProtocol`
 *
 *  AdhereToOBWidgetViewProtocol        <-- This is our helper macro.  It defines all the properties for your class so you don't have to
 *
 *  @end
 *
 *
 *  That's it.  Now you can create a new instance of your MyCustomWidget and use any of the properties defined in the protocol.
 **/

@protocol OBInterstitialViewProtocol <NSObject>

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



@optional
/**
 *  Discussion: 
 *      This is where we attempt to fetch the images.  If you want to fetch images yourself then override this method
 **/
- (void)fetchImageForURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;

@end


/**
 *  Discussion:
 *      Helper macro for having your widget conform to the OBWidgetViewProtocol.
 *      Nobody likes repetitive declarations.
 **/
#define AdhereToOBInterstitialViewProtocol  \
@property (nonatomic, copy) OBWRecommendationTappedHandler recommendationTapHandler; \
- (void)setRecommendationTapHandler:(OBWRecommendationTappedHandler)tapHandler; \
@property (nonatomic, weak) id <OBInterstitialViewDelegate> widgetDelegate; \
@property (nonatomic, strong) OBRequest * request; \
@property (nonatomic, strong) UIView * loadingView;



