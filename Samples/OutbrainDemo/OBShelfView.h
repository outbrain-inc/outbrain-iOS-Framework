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


@protocol OBShelfHeaderDelegate <NSObject>
- (void)brandingDidClick;
@end

/**
 *  Discussion
 *      This recommendation view is a view that should 'hovers' overtop of a content view
 *
 **/

typedef NS_ENUM(NSInteger,OBHoverArrowState) {
    OBHoverArrowStateFlat,      // Flat line
    OBHoverArrowStateLeft,        // Arrow is pointing left
    OBHoverArrowStateRight       // Arrow is pointing right
};



@class OBShelfView;
@protocol OBShelfViewDelegate <NSObject>

@optional
// Called as soon as the tap happens.  In this callback you would stop managing the scroll positions
// yourself.
- (void)userWillExpandShelfView:(OBShelfView *)shelfView;

/**
 *  Called when the user taps to expand the Shelf view.  Or when the user
 *  drags the ShelfView to be fully expanded
 **/
- (void)userDidExpandShelfView:(OBShelfView *)shelfView;


- (void)userWillCollapseShelfView:(OBShelfView *)shelfView;
- (void)userDidCollapseShelfView:(OBShelfView *)shelfView;


/**
 *  Discussion:
 *      Once this is called, then you should dismiss the ShelfView and not
 *      show it again until the parentView is removed from the view and added back on.
 **/
- (void)userDidDismissShelfView:(OBShelfView *)shelfView;

@end



@interface OBShelfView : UIView <OBWidgetViewProtocol, OBShelfHeaderDelegate>

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

/**
 *  Discussion:
 *      This is where we attempt to fetch the images.  If you want to fetch images yourself then override this method
 **/
- (void)fetchImageForURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;



@property (nonatomic, weak) IBOutlet id <OBShelfViewDelegate> delegate;

/**
 *  Discussion:
 *      How much you want this view to 'peek' over the content
 *
 *  Default: 100.f
 **/
@property (nonatomic, assign) CGFloat peekAmount;


- (void)collapseShelfWithFinishBlock:(void (^)(BOOL))finishedBlock;

@end
