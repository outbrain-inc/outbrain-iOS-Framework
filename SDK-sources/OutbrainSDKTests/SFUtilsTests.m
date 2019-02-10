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
    XCTAssertFalse([SFUtils isRTL:@"fdfsd"]);
    XCTAssertFalse([SFUtils isRTL:@"Rafael Nadal engaged to girlfriend of 14 years Mery Perello"]);
    XCTAssertFalse([SFUtils isRTL:nil]);
    XCTAssertFalse([SFUtils isRTL:@""]);
    XCTAssertTrue([SFUtils isRTL:@"בדיקה בדיקה"]);
    XCTAssertTrue([SFUtils isRTL:@"גרמניה נגד פייסבוק: איסוף הנתונים מגורם צד שלישי יוגבל"]);
    XCTAssertTrue([SFUtils isRTL:@"50 דרכים להוריד משקל במהירות"]);
}
@end
