//
//  OBContentTest.m
//  OutbrainSDK
//
//  Created by Joseph Ridenour on 12/23/13.
//  Copyright (c) 2013 Mercury. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "OBContent_Private.h"

#import "OBImage.h"
#import "OBResponse.h"
#import "OBRecommendation.h"

#import "OBDefines.h"

/**
 *  Test that our OB content objects get created propertly
 *  given different data
 **/

@interface OBContentTest : XCTestCase


@end

@implementation OBContentTest


#pragma mark - General Parsing

- (void)testContentConverter
{
    OBAssertNotNilAndProperClass([OBContent convertedValue:@"2008-04-13 00:00" withClass:[NSDate class]], [NSDate class]);
    OBAssertNotNilAndProperClass([OBContent convertedValue:@"http://google.com" withClass:[NSURL class]], [NSURL class]);
    OBAssertNotNilAndProperClass([OBContent convertedValue:@"http://google.com/hello world" withClass:[NSURL class]], [NSURL class]);   // Allow unescaped strings
    OBAssertNotNilAndProperClass([OBContent convertedValue:@"http://google.com/hello world/?query=1123" withClass:[NSURL class]], [NSURL class]);
    OBAssertNotNilAndProperClass([OBContent convertedValue:@"http://google.com/hello world/?query=1234#mobileContentID=51234" withClass:[NSURL class]], [NSURL class]);
}


#pragma mark - OBImage Tests

- (void)testFullImagePayload
{
    OBImage *image = [OBImage contentWithPayload:@{@"url":@"http://placekitten.com/100/100",@"width":@(100.f),@"height":@"75.f"}];
    
    OBAssertNotNilAndProperClass(image, [OBImage class]);
    
    XCTAssertEqual(image.width, (CGFloat)100, @"Width should be 100");
    XCTAssertEqual(image.height, (CGFloat)75, @"Height should be 75");
    
    OBAssertNotNilAndProperClass(image.url, [NSURL class]);
}

- (void)testPartialImagePayload
{
    XCTAssertNil([OBImage contentWithPayload:@{}], @"Image payload without url should be nil");
    XCTAssertNil([OBImage contentWithPayload:@{@"width":@(700)}], @"Image payload without url should be nil");
}


#pragma mark - OBRecommendation Tests

- (NSDictionary *)_recommendationTestPayload
{
    return @{
        @"author": @"",
        @"content": @"Aniboom & Radiohead",
        @"orig_url": @"http://www.webx0.com/aniboom/",
        @"publish_date": @"2008-04-13 00:00",
        @"same_source": @"true",
        @"source_name": @"Web X.0",
        @"thumbnail": @{
            @"height": @109,
            @"imageImpressionType": @"DOCUMENT_IMAGE",
            @"url": @"http://images.outbrain.com/imageserver/v2/s/6/n/Tp4qT/abc/HMovs/Tp4qT-SNp-109x109.jpg",
            @"width": @109
        },
        @"url": @"http://traffic.outbrain.com/network/redir?key=3fe19d454a8325fbd9aaa73d102494d2&rdid=552431590&type=MRD_/E2_la&in-site=true&idx=0&req_id=1e0d8a926aedbcc06bceb52dc43c06e1&agent=blog_JS_rec&recMode=11&reqType=1&wid=100&imgType=2&refPub=23&prs=true&scp=false&origSrc=6"
    };
}

- (void)testFullRecommendationPayload
{
    NSMutableDictionary * recommendationPayload = [[self _recommendationTestPayload] mutableCopy];
    OBRecommendation * recommendation = [OBRecommendation contentWithPayload:recommendationPayload];
    
    OBAssertNotNilAndProperClass(recommendation, [OBRecommendation class]);
    OBAssertNotNilAndProperClass(recommendation.sourceURL, [NSURL class]);
    OBAssertNotNilAndProperClass(recommendation.publishDate, [NSDate class]);
    OBAssertNotNilAndProperClass(recommendation.image, [OBImage class]);
}

@end
