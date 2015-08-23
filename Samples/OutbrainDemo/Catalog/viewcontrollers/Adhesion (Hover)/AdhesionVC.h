//
//  AdhesionVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/3/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBAdhesionView.h"



/**
 *  Discussion:
 *      The adhesion widget is invisioned to be displayed within a vertically
 *      scrolling view.  The adhesion view should 'hover' above the scrollable content. 
 *      You can also use this within a static view if you want.  
 **/


@interface AdhesionVC : UIViewController <OBAdhesionViewDelegate, UIScrollViewDelegate, OBWidgetViewDelegate>

@property (nonatomic, weak) IBOutlet OBAdhesionView * adhesionView;

@end
