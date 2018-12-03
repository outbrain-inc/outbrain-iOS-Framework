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
    
    // Initialize appearance here.
    [self initializeForiPhone];
}

- (void)initializeForiPhone
{
    [JLoadingView showLoadingViewInView:self.window.rootViewController.view withDelay:2.5f animated:NO];
}

- (void)initializeForiPad
{
    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    splitViewController.delegate = self;
    
    UINavigationController * nav = splitViewController.viewControllers[0];
    
    PostsListVC * listVC = (PostsListVC *)[nav topViewController];
    
    PostsSwipeVC * detailVC = (PostsSwipeVC *)[[[splitViewController.viewControllers lastObject] viewControllers] firstObject];
    listVC.detailVC = detailVC;
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
