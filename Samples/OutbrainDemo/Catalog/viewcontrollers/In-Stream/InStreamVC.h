//
//  InStreamVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/31/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBRecommendationSlideCell.h"

@interface InStreamVC : UITableViewController <OBWidgetViewDelegate>
@property (nonatomic, strong) OBRecommendationResponse * response;
@end
