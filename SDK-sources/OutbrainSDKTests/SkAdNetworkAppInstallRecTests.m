//
//  SkAdNetworkAppInstallRecTests.m
//  SkAdNetworkAppInstallRecTests
//
//  Created by oded regev on 09/06/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"

@interface OBRecommendation (Testing)

+ (instancetype)contentWithPayload:(NSDictionary *)payload;

@end


@interface SkAdNetworkAppInstallRecTests : XCTestCase

@property (nonatomic, strong) OBRecommendation *rec;

@end

@implementation SkAdNetworkAppInstallRecTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    NSDictionary *recJson = [OBTestUtils JSONFromFile: @"app_install_ios14_rec"];
    XCTAssertNotNil(recJson);
    self.rec = [OBRecommendation contentWithPayload:recJson];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testAppInstallRecSkAdNetworkDataParse {
    
    XCTAssertNotNil(self.rec);
    XCTAssertNotNil(self.rec.skAdNetworkData);
    
    XCTAssert([self.rec.skAdNetworkData.adNetworkId isEqualToString:@"97r2b46745.skadnetwork"]);
    XCTAssert([self.rec.skAdNetworkData.campaignId intValue] == 33);
    XCTAssert(self.rec.skAdNetworkData.timestamp == 1601792957748);
    XCTAssert([self.rec.skAdNetworkData.iTunesItemId isEqualToString:@"866450515"]);
    XCTAssert([self.rec.skAdNetworkData.nonce isEqualToString:@"feb35745-f54f-416f-b961-6b79c749507c"]);
    XCTAssert([self.rec.skAdNetworkData.signature isEqualToString:@"MDUCGG6IpdcS+8/XTe9TM0/j3JWJ0ajzefVVfgIZAKo/92CtCPcyxjJz9DqSfm3TSTgHVk0gAg=="]);
    XCTAssert([self.rec.skAdNetworkData.skNetworkVersion isEqualToString:@"2.0"]);
    XCTAssert([self.rec.skAdNetworkData.sourceAppId isEqualToString:@"331786748"]);
}



@end
