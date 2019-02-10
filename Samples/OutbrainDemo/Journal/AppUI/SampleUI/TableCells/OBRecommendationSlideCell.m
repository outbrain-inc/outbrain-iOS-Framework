//
//  OBRecommendationSlideCell.m
//  OutbrainDemo
//
//  Created by Oded Regev on 12/31/13.
//  Copyright (c) 2013 Outbrain inc Intermedia. All rights reserved.
//

#import "OBRecommendationSlideCell.h"
#import "OBDemoDataHelper.h"
#import "OBHorizontalWidget.h"

#import <OutbrainSDK/OutbrainSDK.h>


@interface OBRecommendationSlideCell ()

@property (weak, nonatomic) IBOutlet OBHorizontalWidget *obHorizontalWidget;


@end


@implementation OBRecommendationSlideCell

-(void) setOBRequest:(OBRequest *)obRequest {
    [self.obHorizontalWidget setOBRequest:obRequest];
}

-(void) setRecommendationResponse:(OBRecommendationResponse *)recommendationResponse {
    self.obHorizontalWidget.recommendationResponse = recommendationResponse;
}

-(void) setWidgetDelegate:(id<OBWidgetViewDelegate>)widgetDelegate {
    self.obHorizontalWidget.widgetDelegate = widgetDelegate;
}

@end
