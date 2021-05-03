//
//  OBAppDelegate.m
//  OutbrainDemo
//
//  Created by Oded Regev on 12/19/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import "OBAppDelegate.h"
#import "OBDemoDataHelper.h"

#import "PostsListVC.h"
#import "PostsSwipeVC.h"

#import "JLoadingView.h"

#import "OBRecommendationWebVC.h"

@interface OBAppDelegate()<UISplitViewControllerDelegate>

@end

@implementation OBAppDelegate

NSString *const SHOULD_TEST_PLATFORM_KEY =                  @"SHOULD_TEST_PLATFORM_KEY";
NSString *const SHOULD_TEST_PLATFORM_BUNDLE_REQUEST_KEY =   @"SHOULD_TEST_PLATFORM_BUNDLE_REQUEST_KEY";
NSString *const PLATFORM_SAMPLE_BUNDLE_URL =                @"https://play.google.com/store/apps/details?id=com.outbrain";
NSString *const PLATFORM_SAMPLE_PORTAL_URL =                @"https://lp.outbrain.com/increase-sales-native-ads/";
NSString *const PLATFORM_SAMPLE_WIDGET_ID =                 @"SDK_1";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self initWholeApp];
    return YES;
}

- (void)initWholeApp {
    // First thing you should do is initialize outbrain with your given partnerKey
    // @note:  Here we are using a build in Demo partner key.  This will not work on distribution builds.
    //         should only be used for debugging
    [Outbrain initializeOutbrainWithPartnerKey:@"iOSSampleApp2014"];
    
    [Outbrain setTestMode:YES]; // Skipping all billing, statistics, information gathering, and all other action mechanisms.
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOULD_TEST_PLATFORM_KEY];
    
    // Initialize appearance here.
    [self initializeForiPhone];
}

- (void)initializeForiPhone
{
    [JLoadingView showLoadingViewInView:self.window.rootViewController.view withDelay:2.5f animated:NO];
}


#pragma mark - Actions

- (IBAction)showOutbrainAbout
{
    [self showOutbrainAbout:self.window.rootViewController];
}

- (IBAction)showOutbrainAbout:(UIViewController *)vc
{
    NSURL *url = [Outbrain getOutbrainAboutURL];
    SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
    [vc presentViewController:sf animated:YES completion:nil];
}




@end
