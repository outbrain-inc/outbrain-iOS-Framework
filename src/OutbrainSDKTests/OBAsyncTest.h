
//
//  OBAsyncTest_OBAsyncTest.h
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/27/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <SenTestingKit/SenTestCase.h>


/**
 *  This is a base class to be used if your test requires any asynchrounous
 *  operations.
 **/

@interface OBAsyncTest : SenTestCase
/**
 *  Tells whether the asynchronous test is finished or not
 **/
@property (nonatomic, assign, getter = isDone) BOOL done;

/**
 *  Wrap this in an STAssert to recognize timeout as a failure.
 **/
- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs;


@end
