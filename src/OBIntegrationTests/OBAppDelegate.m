//
//  OBAppDelegate.m
//  OB SDK Tests
//
//  Created by Joseph Ridenour on 12/30/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBAppDelegate.h"

#import "OBWebViewController.h"
#import "OutbrainSDK.h"
#import "Outbrain_Private.h"

@implementation OBAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSUserDefaults * ud = [NSUserDefaults standardUserDefaults];
    
    // If we haven't set these in user defaults, then go ahead and set them now.
    // Should only happen once.  This way we can configure these through the Settings.app
    if(![ud valueForKey:@"partner_key"])
        [ud setValue:@"iOSSampleApp2014" forKey:@"partner_key"];
    if(![ud valueForKey:@"ob_widget_id"])
        [ud setValue:@"NA" forKey:@"ob_widget_id"];
    if(![ud valueForKey:@"ob_base_url"])
        [ud setValue:@"http://mobile-demo.outbrain.com" forKey:@"ob_base_url"];
    
    [ud synchronize];
    
    // Initialize the Outbrain SDK
    [Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:[[NSUserDefaults standardUserDefaults] valueForKey:@"partner_key"]}];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[OBWebViewController new]];
    [nav setToolbarHidden:NO];
    self.window.rootViewController = nav;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults] setValue:[Outbrain OBSettingForKey:OBSettingsAttributes.appUserTokenKey] forKey:@"ob_user_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
@end
