//
//  OBAsyncTest.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/27/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBAsyncTest.h"


@implementation OBAsyncTest

- (void)setUp
{
    [super setUp];
    self.done = NO;
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if([timeoutDate timeIntervalSinceNow] < 0.0)
            break;
    } while (!self.isDone);
    
    return self.isDone;
}

//- (BOOL)waitForCompletion:(NSInteger)timeoutSecs
//{
//    // Determine the date which should cause timeout
//    NSDate *timeoutDate = [[NSDate date] dateByAddingTimeInterval:timeoutSecs];
//    
//    // While we're !done, and we haven't passed our timeoutDate,
//    // We should keep running the current run loop.
//    // This will cause the test that uses this to block until 1 of these conditions are met.
//    do {
//        NSDate *curDate = [NSDate date];
//        if([curDate compare:timeoutDate] == NSOrderedDescending)
//        {
//            break;
//        } else {
//            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[[NSDate date] dateByAddingTimeInterval:.01]];
//        }
//    } while (!self.isDone);
//    
//    
//    
//    return self.isDone;
//}

@end
