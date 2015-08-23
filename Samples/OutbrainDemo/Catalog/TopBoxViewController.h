//
//  TopBoxViewController.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 2/16/15.
//  Copyright (c) 2015 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBTopBoxView.h"



/**
 *  Discussion:
 *      The adhesion widget is invisioned to be displayed within a vertically
 *      scrolling view.  The adhesion view should 'hover' above the scrollable content.
 *      You can also use this within a static view if you want.
 **/


@interface TopBoxViewController : UIViewController <UIScrollViewDelegate, OBWidgetViewDelegate> {
    BOOL    _scrolledDown;
    BOOL    _topBoxLocked;
    BOOL    _topBoxDocked;
    
    float   _previousScrollYOffset;
    
    IBOutlet UIScrollView   *mainScrollView;
    IBOutlet UILabel        *mainTextView;
}

@property (nonatomic, strong) IBOutlet OBTopBoxView *topBoxView;
@property (nonatomic, strong) IBOutlet UIScrollView   *mainScrollView;
@property (nonatomic, strong) IBOutlet UILabel        *mainTextView;
@end
