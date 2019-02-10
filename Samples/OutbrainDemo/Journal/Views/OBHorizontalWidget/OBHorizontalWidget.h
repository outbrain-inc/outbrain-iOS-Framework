//
//  OBHorizontalWidget.h
//  Journal
//
//  Created by oded regev on 11/5/17.
//  Copyright © 2017 Outbrain inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBWidgetViewProtocol.h"

@interface OBHorizontalWidget : UIView <UICollectionViewDelegate, UICollectionViewDataSource, OBWidgetViewProtocol>


/**
 *  Discussion:
 *      Delegate style handler for those who don't like using the block style handlers.
 *
 **/
@property (nonatomic, weak) id <OBWidgetViewDelegate> widgetDelegate;

/**
 *  Discussion:
 *      This is the actual response given from the sdk.
 **/
@property (nonatomic, strong) OBRecommendationResponse *recommendationResponse;

/**
 *  Discussion:
 *      Set this to allow Viewability feature to work with OBHorizontalWidget
 *      @param obRequest - The OBRequest to be associated with this OBLabel
 *
 **/
-(void) setOBRequest:(OBRequest *)obRequest;


@end
