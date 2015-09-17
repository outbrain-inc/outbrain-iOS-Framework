//
//  OBResponseTest.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/23/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import "OBRecommendationResponse.h"
#import "OBContent_Private.h"

#import "OBDefines.h"


@interface OBResponseTest : SenTestCase

@end

@implementation OBResponseTest

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testNoRecommendations
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"0-recommendations" ofType:@"json"];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:(0) error:nil];
    OBRecommendationResponse *res = [OBRecommendationResponse contentWithPayload:response[@"response"]];
    OBAssertNotNilAndProperClass(res, [OBRecommendationResponse class]);
    OBAssertNotNilAndProperClass(res.recommendations, [NSArray class]);
    
    STAssertTrue(res.recommendations.count == 0, @"Should have 0 recommendations");
}

- (void)testFullResponseWithImages
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"full response images" ofType:@"json"];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:(0) error:nil];
    OBRecommendationResponse *res = [OBRecommendationResponse contentWithPayload:response[@"response"]];
    OBAssertNotNilAndProperClass(res, [OBRecommendationResponse class]);
    OBAssertNotNilAndProperClass(res.recommendations, [NSArray class]);
    
    STAssertTrue(res.recommendations.count == 18, @"Should have 18 recommendations");
    
    for(OBRecommendation *rec in res.recommendations)
    {
        OBAssertNotNilAndProperClass(rec, [OBRecommendation class]);
        OBAssertNotNilAndProperClass(rec.image, [OBImage class]);
    }
}

- (void)testFullResponseWithoutImages
{
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"full response no images" ofType:@"json"];
    NSDictionary *response = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:path] options:(0) error:nil];
    OBRecommendationResponse *res = [OBRecommendationResponse contentWithPayload:response[@"response"]];
    OBAssertNotNilAndProperClass(res, [OBRecommendationResponse class]);
    OBAssertNotNilAndProperClass(res.recommendations, [NSArray class]);
    
    STAssertTrue(res.recommendations.count == 18, @"Should have 18 recommendations");
    for(OBRecommendation *rec in res.recommendations)
    {
        OBAssertNotNilAndProperClass(rec, [OBRecommendation class]);
        STAssertNil(rec.image, @"Image should be nil");
    }
}

@end
