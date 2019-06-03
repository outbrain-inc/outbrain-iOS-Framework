//
//  OutbrainSDKTests.m
//  OutbrainSDKTests
//
//  Created by Oded Regev on 12/9/13.
//  Copyright (c) 2013 Outbrain inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OutbrainSDK.h"


@interface OutbrainSDKTests : XCTestCase
@end


@interface OBViewabilityService (Testing)

-(NSString *) editTmParameterInUrl:(NSString *)urlString tm:(NSString *)tm;

@end


#define OB_TEST_PARTNER_KEY OBDemoPartnerKey

@implementation OutbrainSDKTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDecodeHTMLEncodedString {
    NSString *testEncodedString = @"Netflix’s New Trailer for &#x2018;Nailed It! Holiday&#x2019; Is Proof Your Cooking Skills Could Be Worse";
    NSString *decodedString = [OBUtils decodeHTMLEnocdedString: testEncodedString];
    XCTAssertNotNil(decodedString);
    XCTAssert([decodedString isEqualToString:@"Netflix’s New Trailer for ‘Nailed It! Holiday’ Is Proof Your Cooking Skills Could Be Worse"]);
    
    testEncodedString = @"Roger Federer's tears for former coach: 'Never broke down like this'";
    decodedString = [OBUtils decodeHTMLEnocdedString: testEncodedString];
    XCTAssert([decodedString isEqualToString:testEncodedString]);
    
    testEncodedString = @"If you can&#39;t beat the robot, make them";
    decodedString = [OBUtils decodeHTMLEnocdedString: testEncodedString];
    XCTAssert([decodedString isEqualToString:@"If you can't beat the robot, make them"]);
}

-(void) testAddTMParamToViewablityURL_NoTM {
    NSString *tmValue = @"232";
    NSString *urlNoTM = @"https://mcdp-chidc2.outbrain.com/l?token=42ea5daf3430b7b031c99581cdbbff1e_2465_1558965693396";
    
    NSString *res = [[OBViewabilityService sharedInstance] editTmParameterInUrl:urlNoTM tm:tmValue];
    NSString *expected = [NSString stringWithFormat:@"%@&tm=%@", urlNoTM, tmValue];
    XCTAssert(expected.length > 0);
    XCTAssert([expected isEqualToString:res]);
}

-(void) testAddTMParamToViewablityURL_NoParamsNoTM {
    NSString *tmValue = @"232";
    NSString *urlNoParamsNoTM = @"https://mcdp-chidc2.outbrain.com/l";
    
    NSString *res = [[OBViewabilityService sharedInstance] editTmParameterInUrl:urlNoParamsNoTM tm:tmValue];
    NSString *expected = [NSString stringWithFormat:@"%@?tm=%@", urlNoParamsNoTM, tmValue];
    XCTAssert(expected.length > 0);
    XCTAssert([expected isEqualToString:res]);
}

-(void) testAddTMParamToViewablityURL_WithParamsWithTM {
    NSString *tmValue = @"232";
    NSString *urlWithParamsWithTM = @"https://log.outbrainimg.com/loggerServices/widgetGlobalEvent?rId=a7a219ee9e20fc846946341d3ebd6d75&pvId=67a059883e4d0384383343623b5155cd&sid=5291479&pid=4737&idx=3&wId=1146&pad=1&org=0&tm=0&eT=0";
    
    
    NSString *res = [[OBViewabilityService sharedInstance] editTmParameterInUrl:urlWithParamsWithTM tm:tmValue];
    NSString *expected = [urlWithParamsWithTM stringByReplacingOccurrencesOfString:@"tm=0" withString:@"tm=232"];
    XCTAssert(expected.length > 0);
    XCTAssert([expected isEqualToString:res]);
}

-(void) testAddTMParamToViewablityURL_WithParamsNoTM {
    NSString *tmValue = @"232";
    NSString *urlWithParamsNoTM = @"https://log.outbrainimg.com/loggerServices/widgetGlobalEvent?rId=a7a219ee9e20fc846946341d3ebd6d75&pvId=67a059883e4d0384383343623b5155cd&sid=5291479&pid=4737&idx=3&wId=1146&pad=1&org=0&eT=0";
    
    
    NSString *res = [[OBViewabilityService sharedInstance] editTmParameterInUrl:urlWithParamsNoTM tm:tmValue];
    NSString *expected = [NSString stringWithFormat:@"%@&tm=%@", urlWithParamsNoTM, tmValue];
    XCTAssert(expected.length > 0);
    XCTAssert([expected isEqualToString:res]);
}




@end
