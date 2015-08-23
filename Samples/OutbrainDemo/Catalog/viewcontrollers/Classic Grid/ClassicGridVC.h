//
//  ClassicGridVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/26/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBClassicRecommendationsView.h"

/**
 *  Discussion:
 *      This class is EXACTLY the same as the "ClassicVC".  Except our `recommendationsView` is a
 *      differenc layout type
 **/


@interface ClassicGridVC : UIViewController<OBWidgetViewDelegate>
@property (nonatomic, weak) IBOutlet OBClassicRecommendationsView * recommendationsView;
@end
