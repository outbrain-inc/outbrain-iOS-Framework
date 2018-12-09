//
//  SFUtilsTests.m
//  OutbrainSDKTests
//
//  Created by oded regev on 09/12/2018.
//  Copyright © 2018 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OutbrainSDK.h"
#import "SFUtils.h"

@interface SFUtilsTests : XCTestCase


@end


@implementation SFUtilsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testIsRTL {
    XCTAssert(![SFUtils isRTL:@"fdfsd"]);
    XCTAssert([SFUtils isRTL:@"בדיקה בדיקה"]);
    
    XCTAssert(![SFUtils isRTL:nil]);
    XCTAssert(![SFUtils isRTL:@""]);
}
@end
