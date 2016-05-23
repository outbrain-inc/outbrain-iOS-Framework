//
//  OBRecommendationRequestOperation.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/11/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import "OBRecommendationRequestOperation.h"
#import "OBRequest.h"
#import "OBRecommendation.h"
#import "OBRecommendationResponse.h"

#import "OBErrors.h"

#import "OBContent_Private.h"
#import "Outbrain_Private.h"


@interface OBRecommendationRequestOperation()

@property (nonatomic, strong) NSDate *requestStartDate;

@end


@implementation OBRecommendationRequestOperation


#pragma mark - Parsing

- (void)parseResponseData:(NSData *)responseData
{
    NSError *error = nil;
    NSDictionary *jsonResponse = nil;
    
    if(responseData != nil)
    {
        jsonResponse = [NSJSONSerialization JSONObjectWithData:responseData options:(0) error:&error];
    }
    else
    {
        error = [NSError errorWithDomain:OBGenericErrorDomain code:OBParsingErroCode userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"There was an error parsing the response", @"")}];
    }
    
    
    // Wrap the jsonResponse and error into an OBResponse
    [self createResponseWithDict:jsonResponse withError:error];
}

- (void)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error
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
    
    self.response = response;
}


#pragma mark - Connection Delegate methods

- (void)main
{
    self.requestStartDate = [NSDate date];
    [super main];
}

- (void) taskCompletedWith:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    _responseData = data;
    
    if (error != nil) {
        [self didFailWithError:error];
        return;
    }
    
    if ([self didReceiveResponseReturnedWithError:response] == YES) {
        return;
    }
    
    [self parseResponseData:_responseData];
    [[OBViewabilityService sharedInstance] reportRecsReceived:self.response timestamp:self.requestStartDate];
}


- (BOOL) didReceiveResponseReturnedWithError:(NSURLResponse *)response
{
    NSIndexSet * invalidStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(302, 600)];
    if([invalidStatusCodes containsIndex:[(NSHTTPURLResponse *)response statusCode]])
    {
        NSString * errorDomain = OBNetworkErrorDomain;
        NSString * errorDescription = NSLocalizedString(@"GenericNetworkRecommendationError", @"There was an error getting a response from the server.  Please check your connection and try again.");
        NSInteger errorCode = OBGenericErrorCode;
        
        
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
        [self createResponseWithDict:nil withError:error];
        
        return YES;
    }
    
    return NO;
}


- (void) didFailWithError:(NSError *)error
{

    // Pass back the original error as the `NSUnderlyingErrorKey` since the devs
    // may want to know about it
    NSError * wrappedError = [NSError errorWithDomain:OBNetworkErrorDomain code:OBServerErrorCode
                                             userInfo:@{
                                                        NSUnderlyingErrorKey:error,
                                                        NSLocalizedDescriptionKey:@"There was an error retrieving your recommendations.  Please check your connection and try again"
                                                        }];
    [self createResponseWithDict:nil withError:wrappedError];
}


@end
