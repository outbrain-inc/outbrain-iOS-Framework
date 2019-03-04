//
//  OBView.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 2/25/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import "OBView.h"
#import "UIView+Visible.h"
#import "SFViewabilityService.h"

@interface OBView()

@property (nonatomic, strong) NSTimer *viewVisibleTimer;

@end

@implementation OBView

#define kTIMER_INTERVAL 0.1

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self trackViewability];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self trackViewability];
    }
    
    return self;
}


- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (BOOL) isTimerRunning {
    return ((self.viewVisibleTimer != nil) && [self.viewVisibleTimer isValid]);
}

- (void) trackViewability {
    if ([self isTimerRunning]) { // if timer is currently running for this view there is no need to start another one
        return;
    }
    
    self.viewVisibleTimer = [NSTimer timerWithTimeInterval:kTIMER_INTERVAL
                                                    target:self
                                                  selector:@selector(checkIfViewIsVisible:)
                                                  userInfo:[@{@"view": self} mutableCopy]
                                                   repeats:YES];
    
    self.viewVisibleTimer.tolerance = kTIMER_INTERVAL * 0.5;
    
    [[NSRunLoop mainRunLoop] addTimer:self.viewVisibleTimer forMode:NSRunLoopCommonModes];
    
    
}


- (void)checkIfViewIsVisible:(NSTimer *)timer {
    UIView *view = timer.userInfo[@"view"];
    
    if (!view.superview) {
        // NSLog(@"Warning: The ad view is not in a super view. No visibility tracking will occur.");
        [self.viewVisibleTimer invalidate];
        return;
    }
    
    CGFloat percentVisible = [view percentVisible];
    
    CGFloat secondsVisible = [timer.userInfo[@"secondsVisible"] floatValue];
    
    if (percentVisible >= 0.5 && secondsVisible < self.viewabilityThresholdMilliseconds) {
        timer.userInfo[@"secondsVisible"] = @(secondsVisible + timer.timeInterval);
    } else if (percentVisible >= 0.5 && secondsVisible >= self.viewabilityThresholdMilliseconds) {
        [self reportViewability:timer];
    } else {
        // View is not visible, decide if we want to report that or not
        [timer.userInfo removeObjectForKey:@"secondsVisible"];
    }
}

- (void) reportViewability:(NSTimer *)timer {
    [timer invalidate];
    [[SFViewabilityService sharedInstance] reportViewabilityForOBView:self];
    [self removeFromSuperview];
}

- (void) removeFromSuperview
{
    if (self.viewVisibleTimer) {
        [self.viewVisibleTimer invalidate];
    }
    
    [super removeFromSuperview];
}

@end

