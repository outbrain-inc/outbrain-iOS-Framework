//
//  OBRecommendationSlideCell.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/31/13.
//  Copyright (c) 2013 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "OBWidgetViewProtocol.h"

@class OBRecommendation;
@class OBRecommendationResponse;

/**
 *  Discussion:
 *      This cell supports loading from storyboard, or manually by `initWithStyle:reuseIdentifier:`
 *      This is a swipeable cell (left to right) of outbrain recommendations
 **/

@interface OBRecommendationSlideCell : UITableViewCell <OBWidgetViewProtocol>


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
 *      Set this to allow Viewability feature to work with OBRecommendationSlideCell
 *      @param widgetId - The Widget Id to be associated with this OBLabel
 *      @param url - The URL that the user is currently viewing
 *
 **/
- (void) setUrl:(NSString *)url andWidgetId:(NSString *)widgetId;

/**
 *  Discussion:
 *      This is where we attempt to fetch the images.  If you want to fetch images yourself then override this method
 **/
- (void)fetchImageForURL:(NSURL *)url withCallback:(void(^)(UIImage * image))callback;



@end
