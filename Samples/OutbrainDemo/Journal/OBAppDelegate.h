//
//  OBAppDelegate.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/19/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

/**
 *  The purpose of this sample app is to show off a full demo of various
 *  outbrain integrations
 **/

@interface OBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;



- (IBAction)showOutbrainAbout;

@end
