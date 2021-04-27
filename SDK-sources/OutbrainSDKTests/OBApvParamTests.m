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
#import "SFUtils.h"

@interface OBApvParamTests : XCTestCase

@property (nonatomic, strong) OBRequest *odRequest;
@property (nonatomic, strong) OBPlatformRequest *platformRequest;


@end

@implementation OBApvParamTests




- (void)setUp {
    NSString *const OBDemoWidgetID = @"SDK_1";
    NSString *const OBDemoUrl = @"https://mobile-demo.outbrain.com";
    NSString *const OUTBRAIN_SAMPLE_BUNDLE_URL = @"https://play.google.com/store/apps/details?id=com.outbrain";

    
    self.odRequest = [OBRequest requestWithURL:OBDemoUrl widgetID:OBDemoWidgetID];
    self.platformRequest = [OBPlatformRequest requestWithBundleURL:OUTBRAIN_SAMPLE_BUNDLE_URL lang:@"en" widgetID:OBDemoWidgetID];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testPlatformRequestWithBundleUrl {
    
}


@end
