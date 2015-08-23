//
//  ClassicInterstitialVC.h
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 1/31/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>

#import "OBInterstitialClassicView.h"

@interface ClassicInterstitialVC : UIViewController
@property (nonatomic, weak) IBOutlet OBInterstitialClassicView * classicInterstitialView;
@end
