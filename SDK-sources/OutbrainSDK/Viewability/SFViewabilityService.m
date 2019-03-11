//
//  SFViewabilityService.m
//  OutbrainSDK
//
//  Created by Alon Shprung on 2/28/19.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFViewabilityService.h"
#import "OBNetworkManager.h"

@interface SFViewabilityService()

@property (nonatomic, strong) NSTimer *reportViewabilityTimer;
@property (nonatomic, strong) NSMutableDictionary *itemAlreadyReportedMap;
@property (nonatomic, strong) NSMutableDictionary *itemsToReportMap;
@property (nonatomic, assign) BOOL isLoading;

@end



@implementation SFViewabilityService

#define kREPORT_TIMER_INTERVAL 1.0

NSString * const kLogViewabilityUrl = @"https://log.outbrainimg.com/api/loggerBatch/log-viewability";
NSString * const kViewabilityKeyFor_requestId_position = @"OB_Viewability_Key_%@_%@";

+ (instancetype)sharedInstance
{
    static SFViewabilityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SFViewabilityService alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.itemAlreadyReportedMap = [[NSMutableDictionary alloc] init];
        sharedInstance.itemsToReportMap = [[NSMutableDictionary alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) reportViewabilityForOBView:(OBView *)obview {
    NSDate *timeNow = [NSDate date];
    NSTimeInterval timeInterval = [timeNow timeIntervalSinceDate:obview.smartFeedInitializationTime];
    NSNumber *timeElapsedMillis = @((int)(timeInterval*1000));
    
    for (NSString *pos in obview.positions) {
        NSString *key = [self viewabilityKeyForRequestId:obview.requestId position:pos];
        [self.itemAlreadyReportedMap setValue:@"YES" forKey:key];
        
        NSMutableDictionary *itemMap = [[NSMutableDictionary alloc]init];
        [itemMap setObject:@([pos intValue]) forKey:@"position"];
        [itemMap setObject:timeElapsedMillis forKey:@"timeElapsed"];
        [itemMap setObject:obview.requestId forKey:@"requestId"];
        
        [self.itemsToReportMap setObject:itemMap forKey:key];
    }
}

- (void) startReportViewability {
    self.reportViewabilityTimer = [NSTimer timerWithTimeInterval:kREPORT_TIMER_INTERVAL
                                                    target:self
                                                  selector:@selector(reportViewability)
                                                  userInfo:[@{@"view": self} mutableCopy]
                                                   repeats:YES];
    
    self.reportViewabilityTimer.tolerance = kREPORT_TIMER_INTERVAL * 0.5;
    
    [[NSRunLoop mainRunLoop] addTimer:self.reportViewabilityTimer forMode:NSRunLoopCommonModes];
}

- (BOOL) isAlreadyReportedForRequestId:(NSString *)requestId position:(NSString *)pos {
    NSString *key = [self viewabilityKeyForRequestId:requestId position:pos];
    return ([self.itemAlreadyReportedMap valueForKey:key] != nil);
}

#pragma mark - Private
- (void) reportViewability {
    if ([self.itemsToReportMap count] == 0 || self.isLoading) {
        return;
    }
    NSURL *url = [NSURL URLWithString:kLogViewabilityUrl];
    NSArray *keys = [self.itemsToReportMap allKeys];
    self.isLoading = true;
    [[OBNetworkManager sharedManager] sendPost:url postData:[self.itemsToReportMap allValues] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            [self.itemsToReportMap removeObjectsForKeys:keys];
        } else {
            NSLog(@"Error report viewability per listing %@", error);
        }
        self.isLoading = false;
    }];
}

-(NSString *) viewabilityKeyForRequestId:(NSString *)requestId position:(NSString *)pos {
    return [NSString stringWithFormat:kViewabilityKeyFor_requestId_position, requestId, pos];
}

@end

