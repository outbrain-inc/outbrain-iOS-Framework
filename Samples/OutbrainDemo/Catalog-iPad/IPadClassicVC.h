//
//  ClassicVCViewController.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OBClassicIPadRecommendationsView.h"
#import <OutbrainSDK/OutbrainSDK.h>

@interface IPadClassicVC : UIViewController<OBWidgetViewDelegate>

@property (nonatomic, weak) IBOutlet OBClassicIPadRecommendationsView * recommendationsView;
@end
