//
//  OBGAHelper.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/19/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBGAHelper.h"
#import "OBGAOperation.h"

static NSOperationQueue     *reportQueue;
static NSMutableDictionary  *reportedDictionary;
static NSString             *appKey;
static NSString             *appVersion;

static BOOL shouldReport = YES;

#define MAX_REPORTS_FOR_SAME_STRING 10

@implementation OBGAHelper

+ (void)commonInitIfNeeded {
    if (!reportQueue) {
        reportQueue = [[NSOperationQueue alloc] init];
    }
    if (!reportedDictionary) {
        reportedDictionary = [[NSMutableDictionary alloc] init];
    }
}

+ (void)reportMethodCalled:(NSString *)methodName {
    [self reportMethodCalled:methodName withParams:nil];
}

+ (void)reportMethodCalled:(NSString *)methodName withParams:(NSString *)firstParam, ... NS_REQUIRES_NIL_TERMINATION {    
    NSMutableString *newContentString = [NSMutableString string];
    NSString *paramsString;
    
    va_list args;
    va_start(args, firstParam);
    for (NSString *arg = firstParam; arg != nil; arg = va_arg(args, NSString*))
    {
        [newContentString appendString:arg];
        [newContentString appendString:@","];
    }
    
    paramsString = [newContentString substringToIndex:[newContentString length]];
    
    va_end(args);

    [self reportMethodCalled:methodName withConcreteParams:paramsString];
}

+ (void)reportMethodCalled:(NSString *)methodName withConcreteParams:(NSString *)paramsString shouldForceSend:(BOOL)forceSend {
    [self commonInitIfNeeded];
    if (shouldReport || forceSend) {
        //Make sure we are sending a fixed number of requests of each type every session
        NSString *reportedString = methodName;
        NSNumber *numberOfReportsForTheSameString = [reportedDictionary objectForKey:reportedString];
        
        if (!numberOfReportsForTheSameString) {
            numberOfReportsForTheSameString = [NSNumber numberWithInt:0];
        }
        
        int value = [numberOfReportsForTheSameString intValue];
        numberOfReportsForTheSameString = [NSNumber numberWithInt:value + 1];
        
        if ([numberOfReportsForTheSameString intValue] < MAX_REPORTS_FOR_SAME_STRING) {
            OBGAOperation *reportOperation = [[OBGAOperation alloc] initWithMethodName:methodName withParams:paramsString appKey:appKey appVersion:appVersion];
            [reportQueue addOperation:reportOperation];
            [reportedDictionary setObject:numberOfReportsForTheSameString forKey:reportedString];
        }
    }
}

+ (void)reportMethodCalled:(NSString *)methodName withConcreteParams:(NSString *)paramsString {
    [self reportMethodCalled:methodName withConcreteParams:paramsString shouldForceSend:NO];
}

+ (void)setShouldReportSDKUsage:(BOOL)shouldReportSDKUsage {
    shouldReport = shouldReportSDKUsage;
}

+ (void)setAppKey:(NSString *)anAppKey {
    appKey = anAppKey;
}

+ (void)setAppVersion:(NSString *)aVersion {
    appVersion = aVersion;
}

@end
