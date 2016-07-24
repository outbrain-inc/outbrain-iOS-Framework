//
//  OBViewabilityService.m
//  OutbrainSDK
//
//  Created by Daniel Gorlovetsky on 11/16/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBViewabilityService.h"
#import "OBViewabilityOperation.h"

@interface ViewabilityData : NSObject

@property (nonatomic, strong) NSString *pid;  // publisher id
@property (nonatomic, strong) NSString *sid;  // source id
@property (nonatomic, strong) NSString *wId;  // widget id (wnid from response)
@property (nonatomic, strong) NSString *wRV;  // widget version in long format NOT string(SDK version)
@property (nonatomic, strong) NSString *rId;  // request id - important
@property (nonatomic, strong) NSString *eT;   // event type (0 - received, 3- exposed)
@property (nonatomic, strong) NSString *idx;  // index
@property (nonatomic, strong) NSString *pvId; // pageview id - received from the response
@property (nonatomic, strong) NSString *org;  // number of organic recs
@property (nonatomic, strong) NSString *pad;  // number of paid recs
@property (nonatomic, strong) NSString *tm;   // time of processing request
@property (nonatomic, strong) NSDate *requestStartDate; // helper property, will not be sent to the server

@end

@implementation ViewabilityData



NSString * const EVENT_RECEIVED = @"0";
NSString * const EVENT_EXPOSED = @"3";

NSString * const kRequestStartDate = @"rsd";
NSString * const kTimeSinceFirstLoadRequest = @"tm";
NSString * const kPublisherId = @"pid";
NSString * const kSourceId = @"sid";
NSString * const kWidgetId = @"wId";
NSString * const kWidgetVersion = @"wRV";
NSString * const kRequestId = @"rId";
NSString * const kEventType = @"eT";
NSString * const kIdx = @"idx";
NSString * const kPageviewId = @"pvId";
NSString * const kOrganicRecs = @"org";
NSString * const kPaidRecs = @"pad";


NSString * const kViewabilityUrl = @"http://log.outbrain.com/loggerServices/widgetGlobalEvent";
NSString * const kViewabilityKeyForURL_and_WidgetId = @"OB_Viewability_Key_%@_%@";
float const kThirtyMinutesInSeconds = 30.0 * 60.0;

- (NSString*)description
{
    return [[self toDictionary] description];
}

-(NSDictionary *) toDictionary {
    return @{kTimeSinceFirstLoadRequest : self.tm,
             kPublisherId               : self.pid,
             kSourceId                  : self.sid,
             kWidgetId                  : self.wId,
             kWidgetVersion             : self.wRV,
             kRequestId                 : self.rId,
             kEventType                 : self.eT,
             kIdx                       : self.idx,
             kPageviewId                : self.pvId,
             kOrganicRecs               : self.org,
             kPaidRecs                  : self.pad,
             kRequestStartDate          : self.requestStartDate
             };
}

@end



@interface OBViewabilityService()
@property (nonatomic, strong) NSMutableDictionary *obLabelMap;
@property (nonatomic, strong) NSMutableDictionary *viewabilityDataMap;
@property (nonatomic, strong) NSMutableArray *reqIdAlreadyReportedArray;

@end



@implementation OBViewabilityService

NSString * const kViewabilityEnabledKey = @"kViewabilityEnabledKey";
NSString * const kViewabilityThresholdKey = @"kViewabilityThresholdKey";


+ (instancetype)sharedInstance
{
    static OBViewabilityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OBViewabilityService alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.obLabelMap = [[NSMutableDictionary alloc] init];
        sharedInstance.viewabilityDataMap = [[NSMutableDictionary alloc] init];
        sharedInstance.reqIdAlreadyReportedArray = [[NSMutableArray alloc] init];
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) addOBLabelToMap:(OBLabel *)obLabel {
    NSString *key = [NSString stringWithFormat:kViewabilityKeyForURL_and_WidgetId, obLabel.url, obLabel.widgetId];
    self.obLabelMap[key] = obLabel;
}

- (void) reportRecsReceived:(OBRecommendationResponse *)response timestamp:(NSDate *)requestStartDate {
    
    if ([self isViewabilityEnabled] == NO) {
        return;
    }
    
    NSString *widgetId = response.request.widgetId;
    NSString *url = response.request.url;
    
    // NSLog(@"reportRecsReceived: %@", widgetId);
    
    ViewabilityData *viewabilityData = [[ViewabilityData alloc] init];
    viewabilityData.pid = [response.responseRequest getStringValueForPayloadKey:@"pid"];
    viewabilityData.sid = [[response.responseRequest getNSNumberValueForPayloadKey:@"sid"] stringValue];
    viewabilityData.wId = [[response.responseRequest getNSNumberValueForPayloadKey:@"wnid"] stringValue];
    viewabilityData.wRV = @"01000405"; //TBD
    viewabilityData.rId = [response.responseRequest getStringValueForPayloadKey:@"req_id"];
    viewabilityData.eT = EVENT_RECEIVED;
    viewabilityData.idx = [response.responseRequest getStringValueForPayloadKey:@"idx"];
    viewabilityData.pvId = [response.responseRequest getStringValueForPayloadKey:@"pvId"];
    viewabilityData.org = [response.responseRequest getStringValueForPayloadKey:@"org"];
    viewabilityData.pad = [response.responseRequest getStringValueForPayloadKey:@"pad"];

    NSDate *timeNow = [NSDate date];
    NSTimeInterval executionTime = [timeNow timeIntervalSinceDate:requestStartDate];
    viewabilityData.tm = [@((int)(executionTime*1000)) stringValue];
    viewabilityData.requestStartDate = requestStartDate;
    
    NSDictionary *viewabilityDictionary = [viewabilityData toDictionary];
    NSString *viewabilityKey = [NSString stringWithFormat:kViewabilityKeyForURL_and_WidgetId, url, widgetId];
    [self.viewabilityDataMap setObject:viewabilityDictionary forKey:viewabilityKey];
    
    NSMutableDictionary *viewabilityUrlParamsDictionary = [viewabilityDictionary mutableCopy];
    viewabilityUrlParamsDictionary[kRequestStartDate] = nil;
    NSURL *viewabilityUrl = [self createUrlFromParams:viewabilityUrlParamsDictionary];
    
    OBViewabilityOperation *viewabilityOperation = [OBViewabilityOperation operationWithURL:viewabilityUrl];
    [self.obRequestQueue addOperation:viewabilityOperation];
    
    // call track viewability on matching OBLabel
    OBLabel *matchingOblabel = [self.obLabelMap objectForKey:viewabilityKey];
    if (matchingOblabel != nil) {
        [matchingOblabel trackViewability];
    }
}

- (void) reportRecsShownForOBLabel:(OBLabel *)obLabel {
    NSString *viewabilityKey = [NSString stringWithFormat:kViewabilityKeyForURL_and_WidgetId, obLabel.url, obLabel.widgetId];
    NSDictionary *viewabilityDictionary = [self.viewabilityDataMap objectForKey:viewabilityKey];
    NSString *reqId = viewabilityDictionary[kRequestId];
    
    if ([self.reqIdAlreadyReportedArray containsObject:reqId]) {
        // NSLog(@"reportRecsShownForOBLabel() - trying to report again for the same reqId: %@", reqId);
        return;
    }
    
    if (viewabilityDictionary == nil) {
        // NSLog(@"Error: reportRecsShownForOBLabel() - make sure to register OBLabel with Outbrain (key: %@)", viewabilityKey);
        return;
    }
    
    
    NSDate *requestStartDate = viewabilityDictionary[kRequestStartDate];
    
    if (viewabilityDictionary != nil) {
        NSMutableDictionary *params = [viewabilityDictionary mutableCopy];
        NSDate *timeNow = [NSDate date];
        NSTimeInterval executionTime = [timeNow timeIntervalSinceDate:requestStartDate];
        
        // Sanity check, if executionTime is more than 30 minutes we shouldn't report Viewability since the data is probably not relevant
        if (executionTime > kThirtyMinutesInSeconds) {
            // NSLog(@"Error: reportRecsShownForOBLabel with data older than 30 minutes. (%f)", executionTime / 60.0);
            return;
        }

        params[kTimeSinceFirstLoadRequest] = [@((int)(executionTime*1000)) stringValue];
        params[kEventType] = EVENT_EXPOSED;
        params[kRequestStartDate] = nil;
        
        [self.reqIdAlreadyReportedArray addObject:viewabilityDictionary[kRequestId]];
        NSURL *viewabilityUrl = [self createUrlFromParams:params];
        OBViewabilityOperation *viewabilityOperation = [OBViewabilityOperation operationWithURL:viewabilityUrl];
        [self.obRequestQueue addOperation:viewabilityOperation];
        
        // NSLog(@"reportRecsShownForOBLabel: %@", obLabel.url);
    }
    else {
        // NSLog(@"Error: reportRecsShownForWidgetId() there is no viewabilityDictionary for OBLabel: %@", viewabilityKey);
    }
}

#pragma mark - Viewability Settings
- (void) updateViewabilitySetting:(NSNumber *)value key:(NSString *)key {
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}

- (BOOL) isViewabilityEnabled {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kViewabilityEnabledKey]) {
        NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:kViewabilityEnabledKey];
        return [val boolValue];
    }
    return YES;
}

- (int) viewabilityThresholdMilliseconds {
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kViewabilityThresholdKey]) {
        NSNumber *val = [[NSUserDefaults standardUserDefaults] objectForKey:kViewabilityThresholdKey];
        return [val intValue];
    }
    return 1000;
}


#pragma mark - Private
-(NSURL *) createUrlFromParams:(NSDictionary *)queryDictionary {
    NSURLComponents *components = [NSURLComponents componentsWithString:kViewabilityUrl];
    NSMutableArray *queryItems = [NSMutableArray array];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        for (NSString *key in queryDictionary) {
            NSString *part = [NSString stringWithFormat: @"%@=%@", key, queryDictionary[key]];
            [queryItems addObject: part];
        }
        
        components.query = [queryItems componentsJoinedByString: @"&"];
    }
    else {
        for (NSString *key in queryDictionary) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryDictionary[key]]];
        }
        components.queryItems = queryItems;
    }
    
    return components.URL;
}

@end
