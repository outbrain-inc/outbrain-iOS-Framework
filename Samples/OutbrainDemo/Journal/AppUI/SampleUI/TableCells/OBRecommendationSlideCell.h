//
//  OBRecommendationSlideCell.h
//  OutbrainDemo
//
//  Created by Oded Regev on 12/31/13.
//  Copyright (c) 2013 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBWidgetViewProtocol.h"

@class OBRecommendation;
@class OBRecommendationResponse;

/**
 *  Discussion:
 *      This cell supports loading from storyboard, or manually by `initWithStyle:reuseIdentifier:`
 *      This is a swipeable cell (left to right) of outbrain recommendations
 **/

@interface OBRecommendationSlideCell : UITableViewCell <OBWidgetViewProtocol>


@property (nonatomic, strong) OBRecommendationResponse * recommendationResponse;

/**
 *  Discussion:
 *      Delegate style handler for those who don't like using the block style handlers.
 *
 **/
@property (nonatomic, weak) IBOutlet id <OBWidgetViewDelegate> widgetDelegate;


/**
 *  Discussion:
 *      Set this to allow Viewability feature to work with OBRecommendationSlideCell
 *      @param obRequest - The OBRequest to be associated with this OBLabel
 *
 **/
-(void) setOBRequest:(OBRequest *)obRequest;



@end
