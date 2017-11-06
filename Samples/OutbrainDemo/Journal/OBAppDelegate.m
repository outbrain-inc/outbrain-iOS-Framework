//
//  OBAppDelegate.m
//  OutbrainDemo
//
//  Created by Oded Regev on 12/19/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
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
    NSString * urlString = @"https://www.outbrain.com/what-is/default/en-mobile";
    NSURL *url = [NSURL URLWithString:urlString];
    SFSafariViewController *sf = [[SFSafariViewController alloc] initWithURL:url];
    [self.window.rootViewController presentViewController:sf animated:YES completion:nil];
}


#pragma mark - SplitView Methods for iPad

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    
}

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation
{
    return YES;
}

#pragma mark DEEP_LINKING

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [Outbrain initializeOutbrainWithPartnerKey:@"iOSSampleApp2014"];
    BOOL returnValue = false;
    NSString *articleUrl;
    
    //see if this is should be handled by this app
    if ([[url absoluteString] hasPrefix:@"journal://article/"]) {
        articleUrl = [[url absoluteString] substringFromIndex:[@"journal://article/" length]];
        returnValue = true;
    }
    
    //handle deeplinking
    if (returnValue) {
        PostsSwipeVC *postSwipeVC =  [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"postsSwipeVC"];

        [[OBDemoDataHelper defaultHelper] fetchPostForURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?json=true", articleUrl]] withCallback:^(id postObject, NSError *error) {
        postSwipeVC.posts = [NSMutableArray arrayWithObject:postObject];
        }];
        
        postSwipeVC.currentIndex = 0;
        
        UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:postSwipeVC];
        self.window.rootViewController = nav;
    }
    
    return returnValue;
}

@end
