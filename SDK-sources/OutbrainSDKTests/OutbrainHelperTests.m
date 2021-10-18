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
    NSInteger testsCount = 0;
    
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"widgetJSId"]) {
            XCTAssert([queryItem.value isEqualToString:@"APP_1"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"idx"]) {
            XCTAssert([queryItem.value isEqualToString:@"2"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"url"]) {
            XCTAssert([queryItem.value isEqualToString: @"http://edition.cnn.com/2017/10/02/sport/kosei-inoue-judo-japan-supercoach-interview/index.html"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"format"]) {
            XCTAssert([queryItem.value isEqualToString:@"vjnc"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"installationType"]) {
            XCTAssert([queryItem.value isEqualToString:@"ios_sdk"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"secured"]) {
            XCTAssert([queryItem.value isEqualToString:@"true"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"rtbEnabled"]) {
            XCTAssert([queryItem.value isEqualToString:@"true"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"api_user_id"]) {
            XCTAssertNotNil(queryItem.value);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"rand"]) {
            XCTAssertNotNil(queryItem.value);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"key"]) {
            XCTAssertNotNil(queryItem.value);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"lang"]) {
            XCTFail(@"lang param should not be here");
        }
        else if ([queryItem.name isEqualToString:@"bundleUrl"]) {
            XCTFail(@"bundleUrl param should not be here");
        }
        else if ([queryItem.name isEqualToString:@"portalUrl"]) {
            XCTFail(@"portalUrl param should not be here");
        }
        else if ([queryItem.name isEqualToString:@"darkMode"]) {
            XCTFail(@"darkMode param should not be here");
        }
    }
    
    urlComponents.query = nil;
    XCTAssertEqual(testsCount, 10);
    XCTAssert([urlComponents.string isEqualToString:@"https://odb.outbrain.com/utils/get"]);
}

- (void)testUrlBuilderForPlatformBundleRequest {
    NSString *const OBDemoWidgetID = @"SDK_1";
    NSString *const OUTBRAIN_SAMPLE_BUNDLE_URL = @"https://play.google.com/store/apps/details?id=com.outbrain";

    OBPlatformRequest *platformRequestWithBundle = [OBPlatformRequest requestWithBundleURL:OUTBRAIN_SAMPLE_BUNDLE_URL lang:@"en" widgetID:OBDemoWidgetID];
    platformRequestWithBundle.widgetIndex = 2;
    platformRequestWithBundle.psub = @"sports";

    
    NSURL *urlRequest = [[OutbrainHelper sharedInstance] recommendationURLForRequest:platformRequestWithBundle];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:urlRequest resolvingAgainstBaseURL:NO];
    NSInteger testsCount = 0;
    
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"widgetJSId"]) {
            XCTAssert([queryItem.value isEqualToString:OBDemoWidgetID]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"idx"]) {
            XCTAssert([queryItem.value isEqualToString:@"2"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"bundleUrl"]) {
            XCTAssert([queryItem.value isEqualToString: OUTBRAIN_SAMPLE_BUNDLE_URL]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"lang"]) {
            XCTAssert([queryItem.value isEqualToString:@"en"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"psub"]) {
            XCTAssert([queryItem.value isEqualToString:@"sports"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"url"]) {
            XCTFail(@"url param should not be here");
        }
        else if ([queryItem.name isEqualToString:@"portalUrl"]) {
            XCTFail(@"portalUrl param should not be here");
        }
    }
    
    urlComponents.query = nil;
    XCTAssertEqual(testsCount, 5);
    XCTAssert([urlComponents.string isEqualToString:@"https://odb.outbrain.com/utils/platforms"]);
}

- (void)testUrlBuilderForPlatformPortalRequest {
    NSString *const OBDemoWidgetID = @"SDK_1";
    NSString *const OUTBRAIN_SAMPLE_PORTAL_URL = @"https://lp.outbrain.com/increase-sales-native-ads/";
    
    OBPlatformRequest *platformRequestWithPortal = [OBPlatformRequest requestWithPortalURL:OUTBRAIN_SAMPLE_PORTAL_URL lang:@"en" widgetID:OBDemoWidgetID];
    platformRequestWithPortal.widgetIndex = 2;
    platformRequestWithPortal.psub = @"beauty";
    
    NSURL *urlRequest = [[OutbrainHelper sharedInstance] recommendationURLForRequest:platformRequestWithPortal];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:urlRequest resolvingAgainstBaseURL:NO];
    NSInteger testsCount = 0;
    
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"widgetJSId"]) {
            XCTAssert([queryItem.value isEqualToString:OBDemoWidgetID]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"idx"]) {
            XCTAssert([queryItem.value isEqualToString:@"2"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"portalUrl"]) {
            XCTAssert([queryItem.value isEqualToString: OUTBRAIN_SAMPLE_PORTAL_URL]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"lang"]) {
            XCTAssert([queryItem.value isEqualToString:@"en"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"psub"]) {
            XCTAssert([queryItem.value isEqualToString:@"beauty"]);
            testsCount++;
        }
        else if ([queryItem.name isEqualToString:@"url"]) {
            XCTFail(@"url param should not be here");
        }
        else if ([queryItem.name isEqualToString:@"bundleUrl"]) {
            XCTFail(@"bundleUrl param should not be here");
        }
    }
    
    urlComponents.query = nil;
    XCTAssertEqual(testsCount, 5);
    XCTAssert([urlComponents.string isEqualToString:@"https://odb.outbrain.com/utils/platforms"]);
}

- (void)testBuildODBWithCustomUserId {
    NSString *CUSTOM_USER_ID = @"abcdefg";
    [Outbrain setUserId: CUSTOM_USER_ID];
    NSString *pageURLString = @"http://edition.cnn.com/2017/10/02/sport/kosei-inoue-judo-japan-supercoach-interview/index.html";
    OBRequest *request = [OBRequest requestWithURL:pageURLString widgetID:@"APP_1" widgetIndex:2];
    
    NSURL *odbUrl = [[OutbrainHelper sharedInstance] recommendationURLForRequest:request];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:odbUrl resolvingAgainstBaseURL:NO];
    NSInteger testsCount = 0;
    
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"api_user_id"]) {
            testsCount++;
            XCTAssert([queryItem.value isEqualToString: CUSTOM_USER_ID]);
        }
    }
    
    XCTAssertEqual(testsCount, 1);
    [Outbrain setUserId: nil];
}

- (void)testBuildODBForSmartfeedWithDarkMode {
    SmartFeedManager *manager = [[SmartFeedManager alloc] init];
    manager.darkMode = YES;
    NSString *pageURLString = @"http://edition.cnn.com/2017/10/02/sport/kosei-inoue-judo-japan-supercoach-interview/index.html";
    OBRequest *request = [OBRequest requestWithURL:pageURLString widgetID:@"SDK_1" widgetIndex:0];
    request.isSmartfeed = YES;
    
    NSURL *odbUrl = [[OutbrainHelper sharedInstance] recommendationURLForRequest:request];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:odbUrl resolvingAgainstBaseURL:NO];
    NSInteger testsCount = 0;
    
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"darkMode"]) {
            testsCount++;
            XCTAssert([queryItem.value isEqualToString: @"true"]);
        }
    }
    
    XCTAssertEqual(testsCount, 1);
}

- (void)testBuildODBForSmartfeedWithDarkModeFalse {
    SmartFeedManager *manager = [[SmartFeedManager alloc] init];
    NSString *pageURLString = @"http://edition.cnn.com/2017/10/02/sport/kosei-inoue-judo-japan-supercoach-interview/index.html";
    OBRequest *request = [OBRequest requestWithURL:pageURLString widgetID:@"SDK_1" widgetIndex:0];
    request.isSmartfeed = YES;
    
    NSURL *odbUrl = [[OutbrainHelper sharedInstance] recommendationURLForRequest:request];
    
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithURL:odbUrl resolvingAgainstBaseURL:NO];
    NSInteger testsCount = 0;
    
    for (NSURLQueryItem *queryItem in urlComponents.queryItems) {
        if ([queryItem.name isEqualToString:@"darkMode"]) {
            testsCount++;
            XCTAssert([queryItem.value isEqualToString: @"false"]);
        }
    }
    
    XCTAssertEqual(testsCount, 1);
}

@end
