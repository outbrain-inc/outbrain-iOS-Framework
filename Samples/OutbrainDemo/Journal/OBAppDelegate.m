//
//  OBAppDelegate.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 12/19/13.
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
    if([[[UIDevice currentDevice] systemVersion] intValue] < 7)
    {
        // Generate  a flat navbar background color
        UIGraphicsBeginImageContext(CGSizeMake(1, 44));
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, 1, 44));
        UIImage * navBackgroundImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[UIToolbar appearance] setBackgroundImage:navBackgroundImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
        // Generate our back arrow
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20,22), NO, 0);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect rect = CGContextGetClipBoundingBox(context);
        
        CGFloat lineWidth = 3.f;
        CGContextSetStrokeColorWithColor(context, UIColorFromRGB(0xED8100).CGColor);
        CGContextSetLineWidth(context, lineWidth);
        CGContextSetLineCap(context, kCGLineCapButt);
        CGContextSetLineJoin(context, kCGLineJoinMiter);
        
        CGFloat arrowWidth = 15;
        CGContextMoveToPoint(context, arrowWidth, CGRectGetMinY(rect)+(lineWidth/2.f));
        CGContextAddLineToPoint(context, CGRectGetMinX(rect)+5.f, CGRectGetMidY(rect));
        CGContextAddLineToPoint(context, arrowWidth, CGRectGetMaxY(rect)-(lineWidth/2.f));
        
        CGContextStrokePath(context);
        
        UIImage * backArrowImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [[UIBarButtonItem appearance] setBackButtonBackgroundImage:[backArrowImage stretchableImageWithLeftCapWidth:CGRectGetMaxX(rect)-1 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    }
    
    
    // Setup differently depending on iphone vs. ipad
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self initializeForiPad];
    }
    else
    {
        [self initializeForiPhone];
    }
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
    NSString * urlString = @"http://www.outbrain.com/what-is/default/en-mobile";
    
    UINavigationController * nav = (UINavigationController *)[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"OBWebNavVC"];
    OBRecommendationWebVC * webVC = [nav.viewControllers lastObject];
    [self.window.rootViewController presentViewController:nav animated:YES completion:^{
        [webVC loadURL:[NSURL URLWithString:urlString]];
    }];
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
