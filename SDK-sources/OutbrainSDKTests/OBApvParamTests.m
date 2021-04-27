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
#import "OutbrainHelper.h"
#import "OBRecommendationRequestOperation.h"

@interface OBSettings (Testing)

@property (nonatomic, assign) BOOL apv;

@end


@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end

@interface OutbrainHelper (Testing)

- (void)_updateAPVCacheForResponse:(OBResponse *)response;
- (void)_cleanAPVCache;
- (NSInteger) _getApvCacheSize;
- (BOOL) _getApvForRequest:(OBRequest *)request;

@end


@interface OBApvParamTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *odbResponse;
@property (nonatomic, strong) OBRecommendationResponse *platformResponse;
@property (nonatomic, strong) OBRequest *odbRequest;
@property (nonatomic, strong) OBPlatformRequest *platformRequest;


@end

@implementation OBApvParamTests


- (void)setUp {
    NSString *const OBDemoWidgetID = @"SDK_1";
    NSString *const OBDemoUrl = @"https://mobile-demo.outbrain.com";
    NSString *const OUTBRAIN_SAMPLE_BUNDLE_URL = @"https://play.google.com/store/apps/details?id=com.outbrain";

    [[OutbrainHelper sharedInstance] _cleanAPVCache];
    self.odbRequest = [OBRequest requestWithURL:OBDemoUrl widgetID:OBDemoWidgetID];
    self.platformRequest = [OBPlatformRequest requestWithBundleURL:OUTBRAIN_SAMPLE_BUNDLE_URL lang:@"en" widgetID:OBDemoWidgetID];
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    
    NSDictionary *responseJson = [OBTestUtils JSONFromFile: @"odb_normal_response"];
    XCTAssertNotNil(responseJson);
    OBRecommendationRequestOperation *odbOperation = [[OBRecommendationRequestOperation alloc] initWithRequest:self.odbRequest];
    OBRecommendationRequestOperation *platformOperation = [[OBRecommendationRequestOperation alloc] initWithRequest:self.platformRequest];
    
    self.odbResponse = [odbOperation createResponseWithDict:responseJson withError:nil];
    self.platformResponse = [platformOperation createResponseWithDict:responseJson withError:nil];
    XCTAssertNotNil(self.odbResponse);
    XCTAssertNotNil(self.platformResponse);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testUpdateApvForNewRequest {
    XCTAssertEqual([[OutbrainHelper sharedInstance] _getApvCacheSize], 0);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.odbRequest]);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.platformRequest]);
}

- (void)testUpdateApvForResponseForNewRequest {
    // At the begining we expect APV to be false
    XCTAssertEqual([[OutbrainHelper sharedInstance] _getApvCacheSize], 0);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.odbRequest]);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.platformRequest]);
    XCTAssertEqual([[OutbrainHelper sharedInstance] _getApvCacheSize], 2);
    
    // now we simulate odb response with apv=true
    XCTAssertTrue(self.odbResponse.settings.apv);
    [[OutbrainHelper sharedInstance] _updateAPVCacheForResponse:self.odbResponse];
    [[OutbrainHelper sharedInstance] _updateAPVCacheForResponse:self.platformResponse];
    
    // now we expect the same request with idx 1 to return "true" (idx=0 always returns false)
    [self.odbRequest setWidgetIndex:1];
    [self.platformRequest setWidgetIndex:1];
    XCTAssertTrue([[OutbrainHelper sharedInstance] _getApvForRequest:self.odbRequest]);
    XCTAssertTrue([[OutbrainHelper sharedInstance] _getApvForRequest:self.platformRequest]);
    
    // verify that for idx=0 we always returns false
    [self.odbRequest setWidgetIndex:0];
    [self.platformRequest setWidgetIndex:0];
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.odbRequest]);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.platformRequest]);
}

- (void)testUpdateApvForResponseWhenApvFalseInResponse {
    // At the begining we expect APV to be false
    XCTAssertEqual([[OutbrainHelper sharedInstance] _getApvCacheSize], 0);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.odbRequest]);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.platformRequest]);
    XCTAssertEqual([[OutbrainHelper sharedInstance] _getApvCacheSize], 2);
    
    // now we simulate odb response with apv=true
    self.odbResponse.settings.apv = NO;
    self.platformResponse.settings.apv = NO;
    XCTAssertFalse(self.odbResponse.settings.apv);
    [[OutbrainHelper sharedInstance] _updateAPVCacheForResponse:self.odbResponse];
    [[OutbrainHelper sharedInstance] _updateAPVCacheForResponse:self.platformResponse];
    
    // now we expect the same request with idx 1 to return "false" (idx=0 always returns false)
    [self.odbRequest setWidgetIndex:1];
    [self.platformRequest setWidgetIndex:1];
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.odbRequest]);
    XCTAssertFalse([[OutbrainHelper sharedInstance] _getApvForRequest:self.platformRequest]);
}



@end
