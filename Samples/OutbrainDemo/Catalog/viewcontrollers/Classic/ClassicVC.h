//
//  ClassicVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/18/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBClassicRecommendationsView.h"


/**
 *  Discussion:
 *      This class shows the most basic example of integrating with `OBClassicRecommendationsView`
 *      recommendations widget
 **/



@interface ClassicVC : UIViewController<OBWidgetViewDelegate>


@property (nonatomic, weak) IBOutlet OBClassicRecommendationsView * recommendationsView;

@end