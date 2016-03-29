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

NSString * const kViewabilityUrl = @"http://log.outbrain.com/loggerServices/widgetGlobalEvent";

- (NSString*)description
{
    return [[self toDictionary] description];
}

-(NSDictionary *) toDictionary {
    return @{@"pid": self.pid,
             @"sid" : self.sid,
             @"wId" : self.wId,
             @"wRV" : self.wRV,
             @"rId" : self.rId,
             @"eT" : self.eT,
             @"idx" : self.idx,
             @"pvId" : self.pvId,
             @"org" : self.org,
             @"pad" : self.pad
             };
}

@end


#define OB_VIEWABILITY_KEY_FOR_WIDGET @"OB_VIEWABILITY_KEY_FOR_WIDGET_%@"


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

- (void) reportRecsReceived:(OBRecommendationResponse *)response {
    NSLog(@"response: %@", response);
    
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
    
    NSURL *viewabilityUrl = [self createUrlFromParams:[viewabilityData toDictionary]];
    
    OBViewabilityOperation *viewabilityOperation = [OBViewabilityOperation operationWithURL:viewabilityUrl];
    [self.obRequestQueue addOperation:viewabilityOperation];
}

- (void) reportRecsShownForWidgetId:(NSString *)widgetId {
    
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
