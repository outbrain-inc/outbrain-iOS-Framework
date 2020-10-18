//
//  OBRecommendationRequestOperation.m
//  OutbrainSDK
//
//  Created by Oded Regev on 6/11/17.
//  Copyright (c) 2017 Outbrain inc. All rights reserved.
//

#import "OBRecommendationRequestOperation.h"
#import "OBRequest.h"
#import "OBRecommendation.h"
#import "OBRecommendationResponse.h"
#import "OBAdsChoicesManager.h"
#import "OBErrors.h"
#import "OutbrainHelper.h"
#import "OBNetworkManager.h"
#import "OBContent_Private.h"
#import "OBViewabilityService.h"

@interface OBRecommendationRequestOperation()

@property (nonatomic, strong) NSDate *requestStartDate;
@property (nonatomic, strong) OBRequest * request;
@property (nonatomic, strong) NSURL * url;

@end


@implementation OBRecommendationRequestOperation

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
    [self startODBRequest];
}

#pragma mark - Parsing Reseponse
- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error
{
    if(responseDict == nil || [responseDict objectForKey:@"response"] == nil || [[responseDict objectForKey:@"response"] isKindOfClass:[NSNull class]])
    {
        // Give a blank response so we can get a valid response
        responseDict = @{@"response":@{@"documents":@{}}};
    }
    OBRecommendationResponse *response = [OBRecommendationResponse contentWithPayload:responseDict[@"response"]];
    response.request = self.request;
        
    if(error)
    {
        response.error = error;
    }
    
    return response;
}

- (OBRecommendationResponse *) parseResponseData:(NSData *)responseData
{
    NSError *error = nil;
    NSDictionary *jsonResponse = nil;
    
    if (responseData != nil)
    {
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:(0) error:&error];
    }
    else
    {
        error = [NSError errorWithDomain:OBGenericErrorDomain code:OBParsingErroCode userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"There was an error parsing the response", @"")}];
    }
    
    
    // Wrap the jsonResponse and error into an OBResponse
    return [self createResponseWithDict:jsonResponse withError:error];
}

#pragma mark - Handling Error
- (OBRecommendationResponse *) didFailWithError:(NSError *)error
{
    
    // Pass back the original error as the `NSUnderlyingErrorKey` since the devs
    // may want to know about it
    NSError * wrappedError = [NSError errorWithDomain:OBNetworkErrorDomain code:OBServerErrorCode
                                             userInfo:@{
                                                        NSUnderlyingErrorKey:error,
                                                        NSLocalizedDescriptionKey:@"There was an error retrieving your recommendations.  Please check your connection and try again"
                                                        }];
    return [self createResponseWithDict:nil withError:wrappedError];
}


#pragma mark - Connection methods

- (void)startODBRequest
{
    // We are using semaphore here to promise the operation will be executed synchronously. Otherwise the next operation will
    // start before we receive the ODB response of the first request.
    // This is important because we use fields from the ODB response on the following calls (token, apv, etc, etc).
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    
    self.url = [[OutbrainHelper sharedInstance] recommendationURLForRequest: self.request];
    self.requestStartDate = [NSDate date];
    
     NSLog(@"ODB: %@", self.url);
    
    [[OBNetworkManager sharedManager] sendGet:self.url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        [self taskCompletedWith:data response:response error:error];
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
}

- (void) taskCompletedWith:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    
    OBRecommendationResponse *obRecResponse;
    
    if (error != nil) {
        obRecResponse = [self didFailWithError:error];
        [self notifyAppHandler: obRecResponse];
        return;
    }
    
    if ([self didReceiveResponseReturnedWithError:response] == YES) {
        obRecResponse = [self generateOBRecResponseWithNetworkError:response];
        [self notifyAppHandler: obRecResponse];
        return;
    }
    
    obRecResponse = [self parseResponseData: data];
    if ([[OBViewabilityService sharedInstance] isViewabilityEnabled]) {
        [[OBViewabilityService sharedInstance] reportRecsReceived:obRecResponse timestamp:self.requestStartDate];
    }
    
    [OBAdsChoicesManager reportAdsChoicesPixels: obRecResponse];
    
    // Here we update Settings from the respones
    [[OutbrainHelper sharedInstance] updateODBSettings: obRecResponse];
    
    obRecResponse.recommendations = [OBRecommendationRequestOperation _filterInvalidRecsForResponse: obRecResponse];
    [[OutbrainHelper sharedInstance].tokensHandler setTokenForRequest: self.request response: obRecResponse];
    
    [self notifyAppHandler: obRecResponse];
}

- (void) notifyAppHandler:(OBRecommendationResponse *)response {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.handler)
        {
            self.handler(response);
        }
    });
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

- (OBRecommendationResponse *) generateOBRecResponseWithNetworkError:(NSURLResponse *)response
{
    NSIndexSet * invalidStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(302, 600)];
    NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
    if ([invalidStatusCodes containsIndex: statusCode])
    {
        NSString * errorDomain = OBNetworkErrorDomain;
        NSString * errorDescription = NSLocalizedString(@"GenericNetworkRecommendationError", @"There was an error getting a response from the server.  Please check your connection and try again.");
        NSInteger errorCode = statusCode;
        
        switch ([(NSHTTPURLResponse *)response statusCode]) {
            case 400:
                errorCode = OBInvalidParametersErrorCode;
                errorDescription = NSLocalizedString(@"InvalidRecommendationRequestError", @"The recommendation request you're attempting to make could not be completed becuase of invalid parameters.  Check your widgetID/partnerKey and try again.");
                break;
            case 500:
                errorCode = OBServerErrorCode;
                errorDescription = NSLocalizedString(@"RecommendationServerError", @"There was an internal server error.  Please try again later.  If the problem persists contact outbrain support");
                break;
            default:
                break;
        }
        
        NSError * error = [NSError errorWithDomain:errorDomain code:errorCode userInfo:@{NSLocalizedDescriptionKey:errorDescription}];
        return [self createResponseWithDict:nil withError:error];
    }
    
    return nil;
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
