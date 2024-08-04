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
#import "OBViewabilityService.h"
#import "OBErrorReporting.h"
#import "OBAppleAdIdUtil.h"

@interface SFViewabilityService()

@property (nonatomic, strong) NSTimer *reportViewabilityTimer;
@property (nonatomic, strong) NSMutableDictionary *itemAlreadyReportedMap;
@property (nonatomic, strong) NSMutableDictionary *itemsToReportMap;
@property (nonatomic, strong) NSMutableDictionary *obViewsData;
@property (nonatomic, assign) BOOL isLoading;

@end



@implementation SFViewabilityService

int const OBVIEW_DEFAULT_TAG = 12345678;

NSString * const kLogViewabilityUrl = @"https://log.outbrainimg.com/api/loggerBatch/log-viewability";
NSString * const kT_LogViewabilityUrl = @"https://t-log.outbrainimg.com/api/loggerBatch/log-viewability";
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
        sharedInstance.obViewsData = [[NSMutableDictionary alloc] init];
    });
    
    return sharedInstance;
}

// This is an internal method for unit-tests purpose only
+ (void) resetSharedInstance
{
    SFViewabilityService *sharedInstance = [SFViewabilityService sharedInstance];
    sharedInstance.itemAlreadyReportedMap = [[NSMutableDictionary alloc] init];
    sharedInstance.itemsToReportMap = [[NSMutableDictionary alloc] init];
    sharedInstance.obViewsData = [[NSMutableDictionary alloc] init];
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) configureViewabilityPerListingForCell:(UIView *)cell withSFItem:(SFItemData *)sfItem initializationTime:(NSDate *)initializationTime {
    @try  {
        OBView *existingOBView = (OBView *)[cell viewWithTag: OBVIEW_DEFAULT_TAG];
        if (existingOBView) {
            [existingOBView removeFromSuperview];
        }
        
        NSArray *_positions = (sfItem.positions && sfItem.positions.count > 0) ? sfItem.positions : @[@"0"];
        
        if (![self isAlreadyReportedForRequestId:sfItem.requestId position:_positions[0]]) {
            OBView *obview = [[OBView alloc] initWithFrame:cell.bounds];
            obview.tag = OBVIEW_DEFAULT_TAG;
            obview.opaque = NO;
            [self registerOBView:obview positions:_positions requestId:sfItem.requestId smartFeedInitializationTime: initializationTime];
            obview.userInteractionEnabled = NO;
            [cell addSubview: obview];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception in configureViewabilityPerListingForCell() - %@",exception.name);
        NSLog(@"Reason: %@ ",exception.reason);
        NSString *errorMsg = [NSString stringWithFormat:@"Exception in configureViewabilityPerListingForCell() - %@ - reason: %@", exception.name, exception.reason];
        [[OBErrorReporting sharedInstance] reportErrorToServer:errorMsg];
    }
}

- (void) configureViewabilityPerListingFor:(UIView *)view withRec:(OBRecommendation *)rec {
    @try  {
        NSString *position = rec.position ? rec.position : @"0";
        NSString *requestId = rec.reqId;
        OBView *existingOBView = (OBView *)[view viewWithTag: OBVIEW_DEFAULT_TAG];
        if (existingOBView) {
            [existingOBView removeFromSuperview];
        }
        if (![self isAlreadyReportedForRequestId:requestId position:position]) {
            NSDate *initializationTime = [[OBViewabilityService sharedInstance] initializationTimeForReqId:requestId];
            OBView *obview = [[OBView alloc] initWithFrame:view.bounds];
            obview.tag = OBVIEW_DEFAULT_TAG;
            obview.opaque = NO;
            [self registerOBView:obview positions:@[position] requestId: requestId smartFeedInitializationTime: initializationTime];
            obview.userInteractionEnabled = NO;
            [view addSubview: obview];
        }
    } @catch (NSException *exception) {
        NSLog(@"Exception in configureViewabilityPerListingFor:withRec: - %@ ",exception.name);
        NSLog(@"Reason: %@ ",exception.reason);
        NSString *errorMsg = [NSString stringWithFormat:@"Exception in configureViewabilityPerListingFor:withRec: - %@ - reason: %@", exception.name, exception.reason];
        [[OBErrorReporting sharedInstance] reportErrorToServer:errorMsg];
    }
}

- (void) registerOBView:(OBView *)obView positions:(NSArray *)positions requestId:(NSString *)reqId smartFeedInitializationTime:(NSDate *)initializationTime {
    // we save the key of the first rec in the OBView
    NSString *pos = (positions && positions.count > 0) ? positions[0] : @"0";
    NSString *key = [self viewabilityKeyForRequestId:reqId position:pos];
    obView.key = key;
    
    NSMutableDictionary *obViewData = [[NSMutableDictionary alloc] init];
    
    if (positions) {
        [obViewData setObject:positions forKey:@"positions"];
    }
    if (reqId) {
        [obViewData setObject:reqId forKey:@"requestId"];
    }
    if (initializationTime) {
        [obViewData setObject:initializationTime forKey:@"smartFeedInitializationTime"];
    }
    
    [self.obViewsData setObject:obViewData forKey:key];
}

- (void) reportViewabilityForOBView:(OBView *)obview {
    NSString *key = obview.key;
    NSMutableDictionary *obViewData = [self.obViewsData valueForKey:key];
    NSArray *positions = [obViewData valueForKey:@"positions"];
    NSString *requestId = [obViewData valueForKey:@"requestId"];
    NSDate *smartFeedInitializationTime = [obViewData valueForKey:@"smartFeedInitializationTime"];
    
    NSDate *timeNow = [NSDate date];
    NSTimeInterval timeInterval = [timeNow timeIntervalSinceDate:smartFeedInitializationTime];
    NSNumber *timeElapsedMillis = @((int)(timeInterval*1000));
    
    for (NSString *pos in positions) {
        NSString *key = [self viewabilityKeyForRequestId:requestId position:pos];
        [self.itemAlreadyReportedMap setValue:@"YES" forKey:key];
        
        NSMutableDictionary *itemMap = [[NSMutableDictionary alloc]init];
        if (pos) {
            [itemMap setObject:@([pos intValue]) forKey:@"position"];
        }
        if (timeElapsedMillis) {
            [itemMap setObject:timeElapsedMillis forKey:@"timeElapsed"];
        }
        if (requestId) {
            [itemMap setObject:requestId forKey:@"requestId"];
        }
        
        [self.itemsToReportMap setObject:itemMap forKey:key];
    }
    
    // Viewability widget level (eT=3)
    [[OBViewabilityService sharedInstance] reportRecsShownForRequestId:requestId];
}

- (void) startReportViewabilityWithTimeInterval:(NSInteger)reportingIntervalMillis {
    if (self.reportViewabilityTimer != nil) {
        return;
    }
    CGFloat reportingIntervalsec = (float) reportingIntervalMillis / 1000;
    self.reportViewabilityTimer = [NSTimer timerWithTimeInterval:reportingIntervalsec
                                                    target:self
                                                  selector:@selector(reportViewability)
                                                  userInfo:nil
                                                   repeats:YES];
    
    self.reportViewabilityTimer.tolerance = reportingIntervalsec * 0.5;
    
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
    NSURL *url = [NSURL URLWithString: [OBAppleAdIdUtil isOptedOut] ? kLogViewabilityUrl : kT_LogViewabilityUrl];
    NSArray *keys = [self.itemsToReportMap allKeys];
    self.isLoading = true;
    [[OBNetworkManager sharedManager] sendPost:url postData:[self.itemsToReportMap allValues] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            if (keys != nil) {
                [self.itemsToReportMap removeObjectsForKeys:keys];
            }
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

