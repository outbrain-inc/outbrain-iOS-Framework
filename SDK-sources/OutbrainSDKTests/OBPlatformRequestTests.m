//
//  OBPlatformRequestTests.m
//  OutbrainSDKTests
//
//  Created by Oded Regev on 26/04/2021.
//  Copyright © 2021 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"


@interface OBPlatformRequestTests : XCTestCase



@end

@implementation OBPlatformRequestTests

NSString *const OBDemoWidgetID = @"SDK_1";
NSString *const OBDemoUrl = @"https://mobile-demo.outbrain.com";
NSString *const OUTBRAIN_SAMPLE_BUNDLE_URL = @"https://play.google.com/store/apps/details?id=com.outbrain";
NSString *const OUTBRAIN_SAMPLE_PORTAL_URL = @"https://lp.outbrain.com/increase-sales-native-ads/";


- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPlatformRequestWithBundleUrl {
    OBPlatformRequest *platformRequest = [OBPlatformRequest requestWithBundleURL:OUTBRAIN_SAMPLE_BUNDLE_URL lang:@"en" widgetID:OBDemoWidgetID];
    XCTAssertTrue([platformRequest.bundleUrl isEqualToString:OUTBRAIN_SAMPLE_BUNDLE_URL]);
    XCTAssertTrue([platformRequest.lang isEqualToString:@"en"]);
    XCTAssertTrue([platformRequest.widgetId isEqualToString:OBDemoWidgetID]);
    XCTAssertNil(platformRequest.portalUrl);
    XCTAssertNil(platformRequest.url);
    
}



@end
