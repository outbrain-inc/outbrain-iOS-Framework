//
//  OBAppDelegate.m
//  Catalog
//
//  Created by Joseph Ridenour on 1/16/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "OBAppDelegate.h"
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBRecommendationWebVC.h"

@implementation OBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // STEP 1:  Initialize the outbrain framework
    [Outbrain initializeOutbrainWithPartnerKey:@"iOSSampleApp2014"];
    
    [Outbrain setTestMode:YES]; // Skipping all billing, statistics, information gathering, and all other action mechanisms.
    return YES;
}

- (IBAction)showOutbrainAbout
{
    NSString * urlString = @"http://www.outbrain.com/what-is/default/en-mobile";
    
    UINavigationController * nav = (UINavigationController *)[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"OBWebNavVC"];
    OBRecommendationWebVC * webVC = [nav.viewControllers lastObject];
    [self.window.rootViewController presentViewController:nav animated:YES completion:^{
        [webVC loadURL:[NSURL URLWithString:urlString]];
    }];
}

@end
