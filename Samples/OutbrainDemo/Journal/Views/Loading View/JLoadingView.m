//
//  JLoadingView.m
//  OutbrainDemo
//
//  Created by Joseph Ridenour on 2/4/14.
//  Copyright (c) 2014 Mercury Intermedia. All rights reserved.
//

#import "JLoadingView.h"

@interface JLoadingView()
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@end

@implementation JLoadingView

+ (instancetype)showLoadingViewInView:(UIView *)view withDelay:(CGFloat)delay animated:(BOOL)animated
{
    JLoadingView * lv = [[[self class] alloc] initWithFrame:view.bounds];
    lv.waitTime = delay;
    
    lv.image = [UIImage imageNamed:@"LaunchImage"];
    lv.contentMode = UIViewContentModeCenter;
    lv.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    lv.backgroundColor = UIColorFromRGB(0xF0F0F0);
    
    [view addSubview:lv];
    
    UIActivityIndicatorView * indy = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indy.center = CGPointMake(lv.frame.size.width/2.f, (lv.frame.size.height / 2.f) + 50.f);
    [indy startAnimating];
    indy.alpha = 0.f;
    lv.activityIndicator = indy;
    [lv addSubview:indy];
    
    
    if(animated)
    {
        lv.alpha = 0.f;
        [UIView animateWithDuration:.2f animations:^{
            lv.alpha = 1.f;
        }];
    }
    
    [lv show];
    
    return lv;
}

+ (instancetype)showLoadingViewInView:(UIView *)view animated:(BOOL)animated
{
    return [self showLoadingViewInView:view withDelay:HUGE_VALF animated:animated];
}


#pragma mark - Show Hide

- (void)show
{
    [UIView animateWithDuration:.2f animations:^{
        self.activityIndicator.alpha = 1.f;
    }];
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:self.waitTime];
}

- (void)dismiss
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:_cmd object:nil];
    [UIView animateWithDuration:.5f animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}


@end
