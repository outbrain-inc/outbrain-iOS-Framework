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


#define OB_TEST_PARTNER_KEY OBDemoPartnerKey

@implementation OutbrainSDKTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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




@end
