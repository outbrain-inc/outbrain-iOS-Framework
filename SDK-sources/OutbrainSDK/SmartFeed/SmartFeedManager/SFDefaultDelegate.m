//
//  SFDefaultDelegate.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 4/22/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import "SFDefaultDelegate.h"
#import <SafariServices/SafariServices.h>
#import <OutbrainSDK/Outbrain.h>

@implementation SFDefaultDelegate

-(void) userTappedOnRecommendation:(OBRecommendation *_Nonnull)rec {
    NSURL *url = [Outbrain getUrl:rec];
    [self presentSFSafariViewController:url];
}

-(void) userTappedOnAdChoicesIcon:(NSURL *_Nonnull)url {
    [self presentSFSafariViewController:url];
}

-(void) userTappedOnVideoRec:(NSURL *_Nonnull)url {
    [self presentSFSafariViewController:url];
}

-(void) userTappedOnOutbrainLabeling {
    NSURL *url = Outbrain.getOutbrainAboutURL;
    [self presentSFSafariViewController:url];
}

-(void) presentSFSafariViewController:(NSURL *_Nonnull)url {
    SFSafariViewControllerConfiguration *configuration = [[SFSafariViewControllerConfiguration alloc] init];
    configuration.entersReaderIfAvailable = YES;
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url configuration: configuration];
    UINavigationController *navigationController = (UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    [navigationController presentViewController:safariVC animated:true completion:^{}];
}
@end
