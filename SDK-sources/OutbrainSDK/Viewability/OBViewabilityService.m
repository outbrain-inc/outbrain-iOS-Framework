//
//  OBViewabilityService.m
//  OutbrainSDK
//
//  Created by Oded Regev on 11/16/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import "OBViewabilityService.h"
#import "OBNetworkManager.h"
#import "OBRequest.h"
#import "OBLabel.h"


@interface ViewabilityData : NSObject

@property (nonatomic, strong) NSString *reportServedUrl;  // report served URL
@property (nonatomic, strong) NSString *reportViewedUrl;  // report viewed URL
@property (nonatomic, strong) NSString *rId;  // request id
@property (nonatomic, strong) NSDate *requestStartDate; // helper property, will not be sent to the server

@end

@implementation ViewabilityData

@end



@interface OBViewabilityService()
@property (nonatomic, strong) NSMutableDictionary *obLabelMap;
@property (nonatomic, strong) NSMutableDictionary *viewabilityDataMap;
@property (nonatomic, strong) NSMutableDictionary *obLabelkeyToRequestIdKeyMap;
@property (nonatomic, strong) NSMutableArray *reqIdAlreadyReportedArray;

@end



@implementation OBViewabilityService

NSString * const kViewabilityEnabledKey = @"kViewabilityEnabledKey";
NSString * const kViewabilityThresholdKey = @"kViewabilityThresholdKey";

NSString * const kViewabilityKeyFor_urlhash_widgetId_idx = @"OB_Viewability_Key_%lu_%@_%ld";
NSString * const kViewabilityKeyFor_reqId = @"OB_Viewability_Key_%@";
float const kThirtyMinutesInSeconds = 30.0 * 60.0;


+ (instancetype)sharedInstance
{
    static OBViewabilityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OBViewabilityService alloc] init];
        // Do any other initialisation stuff here
        sharedInstance.obLabelMap = [[NSMutableDictionary alloc] init];
        sharedInstance.viewabilityDataMap = [[NSMutableDictionary alloc] init];
        sharedInstance.obLabelkeyToRequestIdKeyMap = [[NSMutableDictionary alloc] init];
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
    NSString *key = [self viewabilityKeyForOBRequest:obLabel.obRequest];
    // NSLog(@"Outbrain addOBLabelToMap widgetid: %@ - key: %@", obLabel.obRequest.widgetId, key);
    self.obLabelMap[key] = obLabel;
}

- (void) reportRecsReceived:(OBRecommendationResponse *)response timestamp:(NSDate *)requestStartDate {
    
    if ([self isViewabilityEnabled] == NO) {
        return;
    }
    
    // NSLog(@"Outbrain reportRecsReceived: %@", widgetId);
    
    ViewabilityData *viewabilityData = [[ViewabilityData alloc] init];
    viewabilityData.rId = [response.responseRequest getStringValueForPayloadKey:@"req_id"];
    viewabilityData.reportServedUrl = response.settings.viewabilityActions.reportServedUrl;
    viewabilityData.reportViewedUrl = response.settings.viewabilityActions.reportViewedUrl;
    viewabilityData.requestStartDate = requestStartDate;
    
    NSString *viewabilityKeyForRequestId = [self viewabilityKeyForRequestId:viewabilityData.rId];
    
    [self.viewabilityDataMap setObject:viewabilityData forKey:viewabilityKeyForRequestId];
    
    // Adding the key associated with OBLabel to obLabelkeyToRequestIdKeyMap
    // We will use this key only in case OBLabel will be shown
    NSString *viewabilityKeyForOBRequest = [self viewabilityKeyForOBRequest:response.request];
    [self.obLabelkeyToRequestIdKeyMap setObject:viewabilityKeyForRequestId forKey:viewabilityKeyForOBRequest];
    
    NSDate *timeNow = [NSDate date];
    NSTimeInterval timeIntervalSinceRequestStart = [timeNow timeIntervalSinceDate:requestStartDate];
    NSString *timeToProcessRequest = [NSString stringWithFormat:@"%d", (long) (timeIntervalSinceRequestStart * 1000)];
    
    if (viewabilityData.reportServedUrl == nil) {
        NSLog(@"Error - reportRecsReceived, reportServedUrl is nil");
        return;
    }
    
    NSString *viewabilityUrl = [self editTmParameterInUrl:viewabilityData.reportServedUrl tm:timeToProcessRequest];
    
    NSURLComponents *components = [NSURLComponents componentsWithString:viewabilityUrl];
    
    [[OBNetworkManager sharedManager] sendGet:components.URL completionHandler:nil];
    
    // call track viewability on matching OBLabel
    OBLabel *matchingOblabel = [self.obLabelMap objectForKey:viewabilityKeyForOBRequest];
    if (matchingOblabel != nil) {
        [matchingOblabel trackViewability];
    }
}

- (void) reportRecsShownForOBLabel:(OBLabel *)obLabel {
    OBRequest *obRequest = obLabel.obRequest;
    
    NSString *viewabilityKeyForOBRequest = [self viewabilityKeyForOBRequest:obRequest];
    [self reportRecsShownForKey:viewabilityKeyForOBRequest];
}

- (void) reportRecsShownForResponseRequest:(OBResponseRequest *)responseRequest {
    NSString *reqId = [responseRequest getStringValueForPayloadKey:@"req_id"];
    NSString *viewabilityKeyForRequestId = [self viewabilityKeyForRequestId:reqId];
    [self reportRecsShownForKey:viewabilityKeyForRequestId];
}

- (void) reportRecsShownForKey:(NSString *)viewabilityKey {
    
    // OBLabel shown
    NSString *requestIdkeyAsocciatedWithOBLabel = [self.obLabelkeyToRequestIdKeyMap objectForKey:viewabilityKey];
    if (requestIdkeyAsocciatedWithOBLabel != nil) {
        viewabilityKey = requestIdkeyAsocciatedWithOBLabel;
    }
    
    ViewabilityData *viewabilityData = [self.viewabilityDataMap objectForKey:viewabilityKey];
    
    if (viewabilityData == nil) {
        // NSLog(@"Outbrain Error: reportRecsShownForOBLabel() - make sure to register OBLabel with Outbrain (key: %@)", viewabilityKey);
        return;
    }
    
    NSString *reqId = viewabilityData.rId;
    if ([self.reqIdAlreadyReportedArray containsObject:reqId]) {
        // NSLog(@"Outbrain reportRecsShownForOBLabel() - trying to report again for the same reqId: %@", reqId);
        return;
    }
    
    NSDate *requestStartDate = viewabilityData.requestStartDate;
    
    if (viewabilityData != nil) {
        NSDate *timeNow = [NSDate date];
        NSTimeInterval executionTimeInterval = [timeNow timeIntervalSinceDate:requestStartDate];
        
        // Sanity check, if executionTime is more than 30 minutes we shouldn't report Viewability since the data is probably not relevant
        if (executionTimeInterval > kThirtyMinutesInSeconds) {
            // NSLog(@"Outbrain Error: reportRecsShownForOBLabel with data older than 30 minutes. (%f)", executionTime / 60.0);
            return;
        }
        
        
        
        NSString *executionTime = [NSString stringWithFormat:@"%d", (long) (executionTimeInterval * 1000)];
        
        [self.reqIdAlreadyReportedArray addObject:viewabilityData.rId];
        
        if (viewabilityData.reportViewedUrl == nil) {
            NSLog(@"Error - reportRecsReceived, reportViewedUrl is nil");
            return;
        }
        
        NSString *viewabilityUrl = [self editTmParameterInUrl:viewabilityData.reportViewedUrl tm:executionTime];
        
        NSURLComponents *components = [NSURLComponents componentsWithString:viewabilityUrl];
        
        [[OBNetworkManager sharedManager] sendGet:components.URL completionHandler:nil];
        
        // NSLog(@"Outbrain reportRecsShownForOBLabel: key: %@", viewabilityKey);
    }
    else {
        // NSLog(@"Outbrain Error: reportRecsShownForWidgetId() there is no viewabilityDictionary for OBLabel: %@", viewabilityKey);
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
-(NSString *) editTmParameterInUrl:(NSString *)urlString tm:(NSString *)tm {
    NSString *tmQueryString = [@"tm=" stringByAppendingString:tm];
    if ([urlString containsString:@"tm=0"]) {
        return [urlString stringByReplacingOccurrencesOfString:@"tm=0" withString:tmQueryString];
    } else {
        NSURL *url = [NSURL URLWithString:urlString];
        
        if (![urlString length]) {
            return urlString;
        }
        
        NSString *URLString = [[NSString alloc] initWithFormat:@"%@%@%@", [url absoluteString],
                               url.query ? @"&" : @"?", tmQueryString];
        return [[NSURL URLWithString:URLString] absoluteString];
    }
}

-(NSString *) viewabilityKeyForRequestId:(NSString *)reqId {
    return [NSString stringWithFormat:kViewabilityKeyFor_reqId, reqId];
}

-(NSString *) viewabilityKeyForOBRequest:(OBRequest *)obRequest {
    return [self viewabilityKeyForURL:obRequest.url widgetId:obRequest.widgetId widgetIndex:obRequest.widgetIndex];
}

-(NSString *) viewabilityKeyForURL:(NSString *)url widgetId:(NSString *)widgetId widgetIndex:(NSInteger)widgetIndex {
    NSInteger urlHash = [url hash];
    return [NSString stringWithFormat:kViewabilityKeyFor_urlhash_widgetId_idx, (long)urlHash, widgetId, (long)widgetIndex];
}

@end
