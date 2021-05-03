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


@interface OBTokenHandlerTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *odbResponse;
@property (nonatomic, strong) OBRecommendationResponse *platformResponse;
@property (nonatomic, strong) OBRequest *odbRequest;
@property (nonatomic, strong) OBPlatformRequest *platformRequest;
@property (nonatomic, strong) OBRecommendationsTokenHandler *tokenHandler;


@end

@implementation OBTokenHandlerTests


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
    
    self.tokenHandler = [[OBRecommendationsTokenHandler alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testSetTokenForResponseForNewRequest {
    XCTAssertNil([self.tokenHandler getTokenForRequest:self.odbRequest]);
    XCTAssertNil([self.tokenHandler getTokenForRequest:self.platformRequest]);
}

- (void)testSetTokenForPlatformsResponse {
    XCTAssertNil([self.tokenHandler getTokenForRequest:self.platformRequest]);
    [self.tokenHandler setTokenForRequest:self.platformRequest response:self.platformResponse];
    self.platformRequest.widgetIndex = 1;
    XCTAssertTrue([[self.tokenHandler getTokenForRequest:self.platformRequest] isEqualToString: @"MV9iY2FlN2NmNTIzYzJjM2QyYmM0OWMzZGZjZWY4MjZjZl8w"]);
    XCTAssertTrue([self.platformResponse.responseRequest.token isEqualToString: @"MV9iY2FlN2NmNTIzYzJjM2QyYmM0OWMzZGZjZWY4MjZjZl8w"]);
}

- (void)testSetTokenForOdbResponse {
    XCTAssertNil([self.tokenHandler getTokenForRequest:self.odbRequest]);
    [self.tokenHandler setTokenForRequest:self.odbRequest response:self.odbResponse];
    self.odbRequest.widgetIndex = 1;
    XCTAssertTrue([[self.tokenHandler getTokenForRequest:self.odbRequest] isEqualToString: @"MV9iY2FlN2NmNTIzYzJjM2QyYmM0OWMzZGZjZWY4MjZjZl8w"]);
    XCTAssertTrue([self.odbResponse.responseRequest.token isEqualToString: @"MV9iY2FlN2NmNTIzYzJjM2QyYmM0OWMzZGZjZWY4MjZjZl8w"]);
    
    // if widget index=0 the token should be nil
    self.odbRequest.widgetIndex = 0;
    XCTAssertNil([self.tokenHandler getTokenForRequest:self.odbRequest]);
}




@end
