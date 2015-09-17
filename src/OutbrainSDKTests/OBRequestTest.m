//
//  OBRequestTest.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 2/5/14.
//  Copyright (c) 2014 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBRequest.h"
#import "Outbrain.h"
#import "Outbrain_Private.h"

@interface OBRequestTest : XCTestCase
@end

@implementation OBRequestTest

- (void)testEquality
{
    OBRequest * req1 = [OBRequest requestWithURL:@"http://google.com" widgetID:@"NA"];
    OBRequest * req2 = [OBRequest requestWithURL:@"http://google.com" widgetID:@"NA"];
    
  //  XCTAssertEqual(req1, req2, @"Requests should be equal");
    
    req2.widgetIndex = 200;
   //  XCTAssertEqual(req2, req1, @"Requests should be equal even if widgetIndex is different");
    
    req2.widgetId = @"blah";
    XCTAssertFalse([req2 isEqual:req1], @"Requests should not be equal given different widgetIDs");
    
    req2.widgetId = req1.widgetId;
    req1.url = @"http://facebook.com";
    XCTAssertFalse([req2 isEqual:req1], @"Requests should not be equal given different links");
}

- (void)testRequestURL
{
    OBRequest * request = [OBRequest requestWithURL:@"http://google.com" widgetID:@"NA"];
    XCTAssertNotNil([Outbrain _recommendationURLForRequest:request], @"Should not be nil");
    request.mobileId = @"1234";
    XCTAssertNotNil([Outbrain _recommendationURLForRequest:request], @"Should not be nil");
    request.source = @"com.outbrain.journal-ios";
    XCTAssertNotNil([Outbrain _recommendationURLForRequest:request], @"Should not be nil");
}

- (void)testAPVRequest
{
    OBRequest * request = [OBRequest requestWithURL:@"http://google.com" widgetID:@"NA"];
    XCTAssertTrue([[Outbrain _recommendationURLForRequest:request].query rangeOfString:@"apv"].location == NSNotFound, @"Should not have apv param");
    request.widgetIndex = 1;
    XCTAssertTrue([[Outbrain _recommendationURLForRequest:request].query rangeOfString:@"apv"].location == NSNotFound, @"Still should not have apv param");
}

@end
