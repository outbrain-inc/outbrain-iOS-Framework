//
//  OBNetworkTest.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 1/2/14.
//  Copyright (c) 2014 Mercury. All rights reserved.
//

#import "OBNetworkTest.h"
#import "OutbrainSDK.h"
#import "OBDefines.h"

#import "Outbrain_Private.h"


@implementation OBNetworkTest

- (void)setUp
{
    [super setUp];
    [Outbrain initializeOutbrainWithDictionary:@{OBSettingsAttributes.partnerKey:OBDemoPartnerKey}];
}

- (void)tearDown
{
    [super tearDown];
}


#pragma mark - Methods

- (void)testInvalidRecommendationsRequest
{
    // This is for testing if a user gives us a bad widgetID.
    // The request should come back with a 400 status code.
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:kOBInvalidWidgetID];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        OBAssertNotNilAndProperClass(response, [OBRecommendationResponse class]);
        OBAssertNotNilAndProperClass(response.error, [NSError class]);
        STAssertEqualObjects(response.error.domain, OBNetworkErrorDomain, @"Should be network error domain");
        STAssertTrue((response.error.code == OBInvalidParametersErrorCode) || (response.error.code == OBServerErrorCode), @"Should be invalid parameters request error code");
        
        self.done = YES;
    }];
    STAssertTrue([self waitForCompletion:20], @"Should not timeout");
}

- (void)testRecommendationsNetworkCall
{
    OBRequest * request = [OBRequest requestWithURL:kOBValidTestLink widgetID:kOBValidWidgetID];
    [Outbrain fetchRecommendationsForRequest:request withCallback:^(OBRecommendationResponse *response) {
        OBAssertNotNilAndProperClass(response, [OBRecommendationResponse class]);
        OBAssertNotNilAndProperClass(response.request, [OBRequest class]);
        OBAssertNotNilAndProperClass(response.recommendations, [NSArray class]);
        
        STAssertNil(response.error, @"We should not have an error here.  Got error %@", response.error);
        
        self.done = YES;
    }];
    STAssertTrue([self waitForCompletion:20], @"Should not timeout");
}

@end
