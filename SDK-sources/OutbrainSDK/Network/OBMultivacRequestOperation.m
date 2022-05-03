//
//  OBMultivacRequestOperation.m
//  OutbrainSDK
//
//  Created by oded regev on 10/03/2019.
//  Copyright © 2019 Outbrain. All rights reserved.
//

#import "OBMultivacRequestOperation.h"
#import "OBRequest.h"
#import "OBRecommendation.h"
#import "OBRecommendationResponse.h"
#import "OBAdsChoicesManager.h"
#import "OBErrors.h"
#import "OutbrainHelper.h"
#import "OBNetworkManager.h"
#import "OBContent_Private.h"
#import "OBViewabilityService.h"


@interface OBMultivacRequestOperation()

@property (nonatomic, strong) NSDate *requestStartDate;
@property (nonatomic, strong) OBRequest * request;
@property (nonatomic, strong) NSURL * url;

@end

@implementation OBMultivacRequestOperation

- (instancetype)initWithRequest:(OBRequest *)request
{
    self = [super init];
    if(self)
    {
        self.request = request;
    }
    return self;
}

-(void) main {
    [self startMultivacRequest];
}

#pragma mark - Parsing Reseponse
- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict
{
    if(responseDict == nil || [responseDict objectForKey:@"response"] == nil || [[responseDict objectForKey:@"response"] isKindOfClass:[NSNull class]])
    {
        // Give a blank response so we can get a valid response
        responseDict = @{@"response":@{@"documents":@{}}};
    }
    OBRecommendationResponse *response = [OBRecommendationResponse contentWithPayload:responseDict[@"response"]];
    response.request = self.request;
    
    return response;
}

- (void) parseResponseData:(NSData *)responseData
{
    NSError *error = nil;
    NSDictionary *jsonResponse = nil;
    BOOL isViewabilityEnabled = [[OBViewabilityService sharedInstance] isViewabilityEnabled];
    
    if (responseData != nil)
    {
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:(0) error:&error];
    }
    else
    {
        error = [NSError errorWithDomain:OBGenericErrorDomain code:OBParsingErroCode userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"There was an error parsing the response", @"")}];
        [self.multivacDelegate onMultivacFailure:error];
        return;
    }
    
    NSMutableArray<OBRecommendationResponse *> *cardsResponseList = [[NSMutableArray alloc] init];
    BOOL hasMore = [jsonResponse[@"hasMore"] boolValue];
    NSInteger feedIdx = [jsonResponse[@"feedIdx"] integerValue];
    NSArray *cardsJsonArray = jsonResponse[@"cards"];
    for (NSInteger i=0; i< [cardsJsonArray count]; i++) {
        if ([cardsJsonArray[i] valueForKey:@"response"] == nil) {
            NSLog(@"error in multivac parseResponseData - cardsJsonArray[i][response] is nil");
            continue;
        }
        NSDictionary *cardJson = cardsJsonArray[i];
        OBRecommendationResponse *recResponse = [self createResponseWithDict:cardJson];
        if (isViewabilityEnabled) {
            [[OBViewabilityService sharedInstance] reportRecsReceived:recResponse timestamp:self.requestStartDate];
        }
        
        [OBAdsChoicesManager reportAdsChoicesPixels: recResponse];
        
        // Here we update Settings from the respones
        [[OutbrainHelper sharedInstance] updateApvCacheAndViewabilitySettings: recResponse];
        
        recResponse.recommendations = [OBMultivacRequestOperation _filterInvalidRecsForResponse: recResponse];
        [[OutbrainHelper sharedInstance].tokensHandler setTokenForRequest: self.request response: recResponse];
        
        [cardsResponseList addObject:recResponse];
    }
    [self.multivacDelegate onMultivacSuccess:cardsResponseList feedIdx:feedIdx hasMore:hasMore];
}


#pragma mark - Connection methods

- (void)startMultivacRequest
{
    // We are using semaphore here to promise the operation will be executed synchronously. Otherwise the next operation will
    // start before we receive the Multivac response of the first request.
    // This is important because we use fields from the ODB response on the following calls (token, apv, etc, etc).
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    self.url = [[OutbrainHelper sharedInstance] recommendationURLForRequest: self.request];
    self.requestStartDate = [NSDate date];
    
    // NSLog(@"ODB: %@", self.url);
    
    [[OBNetworkManager sharedManager] sendGet:self.url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @try  {
            [self taskCompletedWith:data response:response error:error];
        } @catch (NSException *exception) {
          NSLog(@"Exception in startMultivacRequest() - %@ ",exception.name);
          NSLog(@"Reason: %@ ",exception.reason);
        } @finally  {
           dispatch_semaphore_signal(sema);
        }
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (void) taskCompletedWith:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (error != nil) {
        [self.multivacDelegate onMultivacFailure:error];
        return;
    }
    
    if ([self didReceiveResponseReturnedWithError:response] == YES) {
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        NSString * errorDomain = OBNetworkErrorDomain;
        NSString * errorDescription = NSLocalizedString(@"GenericNetworkMultivacError", @"There was an error getting a response from the server.  Please check your connection and try again.");
        NSInteger errorCode = statusCode;
        NSError * serverError = [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
        [self.multivacDelegate onMultivacFailure:serverError];
        return;
    }
    
    [self parseResponseData: data];
}

- (BOOL) didReceiveResponseReturnedWithError:(NSURLResponse *)response
{
    NSIndexSet * invalidStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(302, 600)];
    if ([invalidStatusCodes containsIndex:[(NSHTTPURLResponse *)response statusCode]])
    {
        return YES;
    }
    
    return NO;
}


+ (NSArray *)_filterInvalidRecsForResponse:(OBRecommendationResponse *)response {
    NSMutableArray *filteredResponse = [[NSMutableArray alloc] init];
    for (OBRecommendation *rec in response.recommendations) {
        if (rec.isPaidLink) {
            [filteredResponse addObject:rec];
        }
        else {
            // Organic
            NSString *stringUrl = [rec performSelector:@selector(originalValueForKeyPath:) withObject:@"orig_url"];
            NSURL *url = [NSURL URLWithString:stringUrl];
            if (url) {
                [filteredResponse addObject:rec];
            }
        }
    }
    return filteredResponse;
}

@end
