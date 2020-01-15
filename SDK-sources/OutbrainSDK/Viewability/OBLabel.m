//
//  CustomUITextView.m
//  ViewabilityApp
//
//  Created by Oded Regev on 1/4/16.
//  Copyright © 2016 Oded Regev. All rights reserved.
//

#import "OBLabel.h"
#import "UIView+Visible.h"
#import "OBViewabilityService.h"


@interface OBLabel()

@property (nonatomic, copy) NSDate *visibleImpressionTime;
@property (nonatomic, strong) NSTimer *viewVisibleTimer;

@end


@implementation OBLabel

const CGFloat KViewThresholdDefault = 1.0;
CGFloat viewThresholdBeforeReportingToServer = 1.0;

#define kTIMER_INTERVAL 0.1

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        if ([[OBViewabilityService sharedInstance] isViewabilityEnabled]) {
            [self trackViewability];
        }
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        if ([[OBViewabilityService sharedInstance] isViewabilityEnabled]) {
            [self trackViewability];
        }
    }

    return self;
}

- (void) dealloc {
    [self stopViewabilityTimer];
}


- (void) drawRect:(CGRect)rect {
    [super drawRect:rect];
}

-(void) setObRequest:(OBRequest *)obRequest {
    _obRequest = [OBRequest requestWithURL:obRequest.url widgetID:obRequest.widgetId widgetIndex:obRequest.widgetIndex];
}

- (BOOL) isTimerRunning {
    return ((self.viewVisibleTimer != nil) && [self.viewVisibleTimer isValid]);
}

- (void) trackViewability {
    if ([self isTimerRunning]) { // if timer is currently running for this view there is no need to start another one
            return;
    }
    
    int viewabilityThresholdMilliseconds = [[OBViewabilityService sharedInstance] viewabilityThresholdMilliseconds];
    viewThresholdBeforeReportingToServer =  viewabilityThresholdMilliseconds / 1000.0;

    __weak OBLabel* weakSelf = self;

    self.viewVisibleTimer = [NSTimer scheduledTimerWithTimeInterval:kTIMER_INTERVAL
                                                             target:weakSelf
                                                           selector:@selector(checkIfViewIsVisible:)
                                                           userInfo:[@{} mutableCopy]
                                                            repeats:YES];
    
    self.viewVisibleTimer.tolerance = kTIMER_INTERVAL * 0.5;
}


- (void) checkIfViewIsVisible:(NSTimer *)timer {
    UIView *view = self;
    
    if (view.superview == nil) {
        // NSLog(@"Warning: The ad view is not in a super view. No visibility tracking will occur.");
        [self stopViewabilityTimer];
        return;
    }
    
    CGFloat percentVisible = [view percentVisible];
    
    CGFloat secondsVisible = [timer.userInfo[@"secondsVisible"] floatValue];
    
    if (percentVisible >= 0.5 && secondsVisible < viewThresholdBeforeReportingToServer) {
        timer.userInfo[@"secondsVisible"] = @(secondsVisible + timer.timeInterval);
    } else if (percentVisible >= 0.5 && secondsVisible >= viewThresholdBeforeReportingToServer) {
        [self reportViewability:timer];
    } else {
        // View is not visible, decide if we want to report that or not
        [timer.userInfo removeObjectForKey:@"secondsVisible"];
    }
}

- (void) reportViewability:(NSTimer *)timer {
//    NSString *trimmedUrlString = [self.url substringFromIndex:MAX((int)[self.url length]-50, 0)]; //in case string is less than 4 characters long.
//    NSLog(@"Reporting viewability for widget id: %@, url: ...%@, shown for %.02f seconds", self.widgetId, trimmedUrlString,
//          [timer.userInfo[@"secondsVisible"] floatValue]);
    [[OBViewabilityService sharedInstance] reportRecsShownForOBLabel:self];

    [self stopViewabilityTimer];
}

- (void) stopViewabilityTimer
{
    [self.viewVisibleTimer invalidate];
    self.viewVisibleTimer = nil;
}

- (void) removeFromSuperview
{
    [self stopViewabilityTimer];
    
    [super removeFromSuperview];
}

@end
