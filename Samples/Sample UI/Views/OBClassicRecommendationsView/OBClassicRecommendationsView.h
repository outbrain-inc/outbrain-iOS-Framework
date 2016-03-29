//
//  OBClassicRecommendationsView.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/16/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "OBWidgetViewProtocol.h"


typedef NS_ENUM(NSInteger, OBClassicRecommendationsViewLayoutType) {
    OBClassicRecommendationsViewLayoutTypeList,
    OBClassicRecommendationsViewLayoutTypeGrid
};


@interface OBClassicRecommendationsView : UIView <OBWidgetViewProtocol>

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
 *      Determines how the view should layout.  
 *
 *  Defaults: OBClassicRecommendationsViewLayoutTypeList
 **/
@property (nonatomic, assign) OBClassicRecommendationsViewLayoutType layoutType;

/**
 *  Discussion:
 *      Set this to no if you do not want to display images.
 * 
 *  Defaults: YES
 **/
@property (nonatomic, assign) BOOL showImages;

/**
 *  Discussion:
 *      Set this to allow Viewability feature to work with OBClassicRecommendationsView
 *
 **/
@property (nonatomic, copy) NSString * widgetId;

/**
 *  Discussion:
 *      Get the hight of the collection view
 *
 *  Defaults: 0
 **/
- (CGFloat) getHeight;


/**
 *  Discussion:
 *      This is where we attempt to fetch the images.  If you want to fetch images yourself then override this method
 **/
- (void)fetchImageForURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;
@end
