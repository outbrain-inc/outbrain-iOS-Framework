//
//  OBCannedNetworkTest.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 1/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "OBNetworkTest.h"
#import "OutbrainSDK.h"
#import "Outbrain_Private.h"
#import "ILCannedURLProtocol.h"

/**
 *  This will do the same thing as OBNetworkTest.  But here we'll return the canned responses for each request.
 **/

@interface OBCannedNetworkTest : OBNetworkTest
@end


@implementation OBCannedNetworkTest

- (void)setUp
{
    [super setUp];
    [NSURLProtocol registerClass:[ILCannedURLProtocol class]];
}

- (void)tearDown
{
    [NSURLProtocol unregisterClass:[ILCannedURLProtocol class]];
    [super tearDown];
}


#pragma mark - Tests

- (void)testInvalidRecommendationsRequest {}    // Disregard

- (void)testRecommendationsNetworkCall
{
    // Need to set the response here
    [ILCannedURLProtocol setCannedStatusCode:200];
    [ILCannedURLProtocol setCannedHeaders:@{@"Content-Type":@"application/json"}];
    [ILCannedURLProtocol setCannedResponseData:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"full response images" ofType:@"json"]]];
    [super testRecommendationsNetworkCall];
}

- (void)testZeroRecommendationsCall
{
    // Return our canned response for this request
    [ILCannedURLProtocol setCannedStatusCode:200];
    [ILCannedURLProtocol setCannedHeaders:@{@"Content-Type":@"application/json"}];
    [ILCannedURLProtocol setCannedResponseData:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"0-recommendations" ofType:@"json"]]];
    
    // Do the request
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:@"CLB"];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        XCTAssertNotNil(response, @"Response should be valid");
        XCTAssertTrue(response.recommendations.count == 0, @"Should have Zero recommendations");
        
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:5], @"Should not timeout since we're serving local data");
}

- (void)testAPVRequests
{
    [ILCannedURLProtocol setCannedStatusCode:200];
    [ILCannedURLProtocol setCannedHeaders:@{@"Content-Type":@"application/json"}];
    [ILCannedURLProtocol setCannedResponseData:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"full response images" ofType:@"json"]]];
    [super testRecommendationsNetworkCall];
    
    // After this request apv should be set and the next request for this widgetID should have apv = true
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:kOBValidWidgetID widgetIndex:1];
    XCTAssertTrue([[Outbrain _recommendationURLForRequest:request].query rangeOfString:@"apv=true"].location != NSNotFound, @"Should have apv=true");
    // Test race condition.  If we request another widget with same ID and 0 index, then apv=true should not be appended
    request.widgetIndex = 0;
    XCTAssertTrue([[Outbrain _recommendationURLForRequest:request].query rangeOfString:@"apv"].location == NSNotFound, @"Should not have apv");
}

@end
