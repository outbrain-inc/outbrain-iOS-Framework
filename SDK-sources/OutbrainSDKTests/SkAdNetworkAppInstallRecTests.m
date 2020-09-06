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
    XCTAssert([self.rec.skAdNetworkData.campaignId isEqualToString:@"33"]);
    XCTAssert([self.rec.skAdNetworkData.iTunesItemId isEqualToString:@"711455226"]);
    XCTAssert([self.rec.skAdNetworkData.nonce isEqualToString:@"e7b315b5-5d3d-4ceb-bb90-b617dee5e173"]);
    XCTAssert([self.rec.skAdNetworkData.signature isEqualToString:@"MDUCGQCNA3MQj19RNnAzSq2HBuJw5Y/GF1egz5cCGED6ncLPofiHKernghDGf7QWcF2fz3FiKg=="]);
    XCTAssert([self.rec.skAdNetworkData.skNetworkVersion isEqualToString:@"1"]);
    XCTAssert([self.rec.skAdNetworkData.sourceAppId isEqualToString:@"331786748"]);
    XCTAssert([self.rec.skAdNetworkData.timestamp isEqualToString:@"1598441577"]);
}



@end
