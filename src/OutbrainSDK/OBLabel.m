//
//  CustomUITextView.m
//  ViewabilityApp
//
//  Created by Oded Regev on 1/4/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

#import "OBLabel.h"
#import "UIView+Visible.h"

@interface OBLabel()

@property (nonatomic, copy) NSDate *visibleImpressionTime;
@property (nonatomic, strong) NSTimer *viewVisibleTimer;

@end


@implementation OBLabel

const CGFloat KViewThresholdBeforeReportingToServer = 1.0;

#define kTIMER_INTERVAL 0.1

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self trackViewability];
    }
    return self;
}

- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSLog(@"Drawing rect: %ld", (long)self.tag);
}

- (void) trackViewability {
    
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
        NSLog(@"Warning: The ad view is not in a super view. No visibility tracking will occur.");
        [self.viewVisibleTimer invalidate];
        return;
    }
    
    CGFloat percentVisible = [view percentVisible];
    
    CGFloat secondsVisible = [timer.userInfo[@"secondsVisible"] floatValue];
    
    if (percentVisible >= 0.5 && secondsVisible < KViewThresholdBeforeReportingToServer) {
        timer.userInfo[@"secondsVisible"] = @(secondsVisible + timer.timeInterval);
    } else if (percentVisible >= 0.5 && secondsVisible >= KViewThresholdBeforeReportingToServer) {
        [self reportViewability:timer];
    } else {
        // View is not visible, decide if we want to report that or not
        [timer.userInfo removeObjectForKey:@"secondsVisible"];
    }
}

- (void) reportViewability:(NSTimer *)timer {
    // TODO report viewability to the server, now use NSLog instead
    NSLog(@"Reporting viewability for view.tag: %ld, widget id: %@, shown for %@ seconds", (long)self.tag, self.widgetId, timer.userInfo[@"secondsVisible"]);
    [timer invalidate];
}

- (void) removeFromSuperview
{
    if (self.viewVisibleTimer) {
        [self.viewVisibleTimer invalidate];
    }
    
    [super removeFromSuperview];
}

@end
