//
//  OBAppDelegate.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/19/13.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

FOUNDATION_EXPORT NSString *const SHOULD_TEST_PLATFORM_KEY;
FOUNDATION_EXPORT NSString *const SHOULD_TEST_PLATFORM_BUNDLE_REQUEST_KEY;
FOUNDATION_EXPORT NSString *const PLATFORM_SAMPLE_BUNDLE_URL;
FOUNDATION_EXPORT NSString *const PLATFORM_SAMPLE_PORTAL_URL;
FOUNDATION_EXPORT NSString *const PLATFORM_SAMPLE_WIDGET_ID;

/**
 *  The purpose of this sample app is to show off a full demo of various
 *  outbrain integrations
 **/

@interface OBAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;



- (IBAction)showOutbrainAbout;
- (IBAction)showOutbrainAbout:(UIViewController *)vc;

@end
