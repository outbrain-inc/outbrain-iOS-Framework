//
//  AdhesionVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBShelfView.h"



/**
 *  Discussion:
 *      The adhesion widget is invisioned to be displayed within a vertically
 *      scrolling view.  The adhesion view should 'hover' above the scrollable content.
 *      You can also use this within a static view if you want.
 **/


@interface ShelfVC : UIViewController <OBShelfViewDelegate, UIScrollViewDelegate, OBWidgetViewDelegate>

@property (nonatomic, weak) IBOutlet OBShelfView * shelfView;

@end
