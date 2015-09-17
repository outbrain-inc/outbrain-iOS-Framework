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
    

//    if(response.recommendations.count == 0 && !error)
//    {
//        error = [NSError errorWithDomain:OBZeroRecommendationseErrorDomain code:OBNoRecommendationsErrorCode userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"No Recommendations", @"The server returned 0 recommendations.  You should retry the request at a later date.")}];
//    }
    
    if(error)
    {
        response.error = error;
    }
    
    self.response = response;
}


#pragma mark - Connection Delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
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
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(!_responseData)
    {
        _responseData = [[NSMutableData alloc] init];
    }
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if([self isCancelled]) return [self setFinished:YES];   // We are cancelled.  No need to parse the responseData
    if(self.response) return [self setFinished:YES];        // We have already set the response.  No need to reset it.
    
    // Everything should be good and ready to parse
    [self parseResponseData:_responseData];
    [self setFinished:YES];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{

    // Pass back the original error as the `NSUnderlyingErrorKey` since the devs
    // may want to know about it
    NSError * wrappedError = [NSError errorWithDomain:OBNetworkErrorDomain code:OBServerErrorCode
                                             userInfo:@{
                                                        NSUnderlyingErrorKey:error,
                                                        NSLocalizedDescriptionKey:@"There was an error retrieving your recommendations.  Please check your connection and try again"
                                                        }];
    [self createResponseWithDict:nil withError:wrappedError];
    [self setFinished:YES];
}


@end
