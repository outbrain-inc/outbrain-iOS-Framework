//
//  OBHoverView.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CAShapeLayer.h>
#import <QuartzCore/CAAnimation.h>

#import "OBWidgetViewProtocol.h"

@class OBRecommendation;
@class OBRecommendationResponse;


/**
 *  Discussion
 *      This recommendation view is a view that should 'hovers' overtop of a content view
 *
 **/

typedef NS_ENUM(NSInteger,OBHoverArrowState) {
    OBHoverArrowStateFlat,      // Flat line
    OBHoverArrowStateUp,        // Arrow is pointing up
    OBHoverArrowStateDown       // Arrow is pointing down
};



@class OBAdhesionView;
@protocol OBAdhesionViewDelegate <NSObject>

@optional
// Called as soon as the tap happens.  In this callback you would stop managing the scroll positions
// yourself.
- (void)userWillExpandAdhesionView:(OBAdhesionView *)adhesionView;

/**
 *  Called when the user taps to expand the adhesion view.  Or when the user
 *  drags the adhesionView to be fully expanded
 **/
- (void)userDidExpandAdhesionView:(OBAdhesionView *)adhesionView;


- (void)userWillCollapseAdhesionView:(OBAdhesionView *)adhesionView;
- (void)userDidCollapseAdhesionView:(OBAdhesionView *)adhesionView;


/**
 *  Discussion:
 *      Once this is called, then you should dismiss the adhesionView and not
 *      show it again until the parentView is removed from the view and added back on.
 **/
- (void)userDidDismissAdhesionView:(OBAdhesionView *)adhesionView;

@end



@interface OBAdhesionView : UIView <OBWidgetViewProtocol>

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
@property (nonatomic, weak) IBOutlet id <OBWidgetViewDelegate> widgetDelegate;

/**
 *  Discussion:
 *      This is the actual response given from the sdk.
 **/
@property (nonatomic, strong) OBRecommendationResponse * recommendationResponse;




@property (nonatomic, weak) IBOutlet id <OBAdhesionViewDelegate> delegate;

/**
 *  Discussion:
 *      The current arrow state
 *
 *  Default: OBArrowStateUp
 **/
@property (nonatomic, assign) OBHoverArrowState arrowState;


/**
 *  Discussion:
 *      How much you want this view to 'peek' over the content
 *
 *  Default: 100.f
 **/
@property (nonatomic, assign) CGFloat peekAmount;


@end
