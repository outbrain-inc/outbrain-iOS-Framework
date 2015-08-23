//
//  OBWidgetViewProtocol.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/7/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OBRecommendationResponse;
@class OBRecommendation;

@protocol OBWidgetViewProtocol;


// Callback defines
typedef void(^OBWRecommendationTappedHandler)(OBRecommendation * recommendation);

@protocol OBWidgetViewDelegate <NSObject>
- (void)widgetView:(UIView<OBWidgetViewProtocol> *)widgetView tappedRecommendation:(OBRecommendation *)recommendation;

@optional
// Some widgets have branding attached to them.  These branding areas are clickable by the user.
// Here you can redirect them to the oubrain about page.
- (void)widgetViewTappedBranding:(UIView<OBWidgetViewProtocol> *)widgetView;
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

@protocol OBWidgetViewProtocol <NSObject>

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

@end


/**
 *  Discussion: 
 *      Helper macro for having your widget conform to the OBWidgetViewProtocol.  
 *      Nobody likes repetitive declarations.
 **/
#define AdhereToOBWidgetViewProtocol \
    @property (nonatomic, copy) OBWRecommendationTappedHandler recommendationTapHandler; \
    - (void)setRecommendationTapHandler:(OBWRecommendationTappedHandler)tapHandler; \
    @property (nonatomic, strong) OBRecommendationResponse * recommendationResponse; \
    @property (nonatomic, weak) IBOutlet id <OBWidgetViewDelegate> widgetDelegate;




