//
//  OutbrainHelperTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 10/8/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OutbrainSDK.h"
#import "OutbrainHelper.h"

@interface OutbrainHelperTests : XCTestCase

@end

@implementation OutbrainHelperTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBuildODB_URL {
    NSString *pageURLString = @"http://edition.cnn.com/2017/10/02/sport/kosei-inoue-judo-japan-supercoach-interview/index.html";
    OBRequest *request = [OBRequest requestWithURL:pageURLString widgetID:@"APP_1" widgetIndex:2];
    
    NSURL *odbUrl = [[OutbrainHelper sharedInstance] recommendationURLForRequest:request];
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:odbUrl resolvingAgainstBaseURL:NO];

    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"widgetJSId"]) {
            XCTAssert([queryItem.value isEqualToString:@"APP_1"]);
        }
        else if ([queryItem.name isEqualToString:@"idx"]) {
            XCTAssert([queryItem.value isEqualToString:@"2"]);
        }
        else if ([queryItem.name isEqualToString:@"url"]) {
            NSLog(@"***** URL: %@", queryItem.value);
            XCTAssert([queryItem.value isEqualToString: pageURLString]);
        }
        else if ([queryItem.name isEqualToString:@"format"]) {
            XCTAssert([queryItem.value isEqualToString:@"vjnc"]);
        }
        else if ([queryItem.name isEqualToString:@"installationType"]) {
            XCTAssert([queryItem.value isEqualToString:@"ios_sdk"]);
        }
        else if ([queryItem.name isEqualToString:@"secured"]) {
            XCTAssert([queryItem.value isEqualToString:@"true"]);
        }
        else if ([queryItem.name isEqualToString:@"rtbEnabled"]) {
            XCTAssert([queryItem.value isEqualToString:@"true"]);
        }
        else if ([queryItem.name isEqualToString:@"api_user_id"]) {
            XCTAssertNotNil(queryItem.value);
        }
        else if ([queryItem.name isEqualToString:@"rand"]) {
            XCTAssertNotNil(queryItem.value);
        }
        else if ([queryItem.name isEqualToString:@"key"]) {
            XCTAssertNotNil(queryItem.value);
        }
    }
    
    urlComponents.query = nil;
    XCTAssert([urlComponents.string isEqualToString:@"https://odb.outbrain.com/utils/get"]);
}

@end
