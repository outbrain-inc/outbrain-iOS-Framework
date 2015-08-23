//
//  ClassicInterstitialVC.h
//  OutbrainDemo
//
//  Created by Daniel Gorlovetsky on 4/6/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OutbrainSDK/OutbrainSDK.h>
#import "OBIPadInterstitialClassicView.h"
#import "OBWidgetViewProtocol.h"

@interface IPadClassicInterstitialVC : UIViewController<OBWidgetViewDelegate>
@property (nonatomic, weak) IBOutlet OBIPadInterstitialClassicView * classicInterstitialView;
@end
