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

@end

@implementation ViewabilityData

NSString * const EVENT_RECEIVED = @"0";
NSString * const EVENT_EXPOSED = @"3";

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
NSString * const kViewabilityKeyForWidgetId = @"OB_Viewability_%@";



- (NSString*)description
{
    return [[self toDictionary] description];
}

-(NSDictionary *) toDictionary {
    return @{kPublisherId   : self.pid,
             kSourceId      : self.sid,
             kWidgetId      : self.wId,
             kWidgetVersion : self.wRV,
             kRequestId     : self.rId,
             kEventType     : self.eT,
             kIdx           : self.idx,
             kPageviewId    : self.pvId,
             kOrganicRecs   : self.org,
             kOrganicRecs   : self.pad
             };
}

@end



@implementation OBViewabilityService

+ (instancetype)sharedInstance
{
    static OBViewabilityService *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OBViewabilityService alloc] init];
        // Do any other initialisation stuff here
    });
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void) reportRecsReceived:(OBRecommendationResponse *)response widgetId:(NSString *)widgetId {
    
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
    
    
    NSDictionary *viewabilityDictionary = [viewabilityData toDictionary];
    
    [[NSUserDefaults standardUserDefaults] setObject:viewabilityDictionary forKey:[NSString stringWithFormat:kViewabilityKeyForWidgetId, widgetId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSURL *viewabilityUrl = [self createUrlFromParams:viewabilityDictionary];
    
    OBViewabilityOperation *viewabilityOperation = [OBViewabilityOperation operationWithURL:viewabilityUrl];
    [self.obRequestQueue addOperation:viewabilityOperation];
}

- (void) reportRecsShownForWidgetId:(NSString *)widgetId {
    NSDictionary *viewabilityDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:kViewabilityKeyForWidgetId, widgetId]];
    
    if (viewabilityDictionary != nil) {
        NSMutableDictionary *params = [viewabilityDictionary mutableCopy];
        params[kEventType] = EVENT_EXPOSED;
        
        NSURL *viewabilityUrl = [self createUrlFromParams:params];
        OBViewabilityOperation *viewabilityOperation = [OBViewabilityOperation operationWithURL:viewabilityUrl];
        [self.obRequestQueue addOperation:viewabilityOperation];
    }
}

-(NSURL *) createUrlFromParams:(NSDictionary *)queryDictionary {
    NSURLComponents *components = [NSURLComponents componentsWithString:kViewabilityUrl];
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in queryDictionary) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryDictionary[key]]];
    }
    components.queryItems = queryItems;
    return components.URL;
}

@end
