//
//  SkAdNetworkAppInstallRecTests.m
//  SkAdNetworkAppInstallRecTests
//
//  Created by oded regev on 09/06/2020.
//  Copyright © 2020 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainManager.h"
#import "OutbrainSDK.h"

@import StoreKit;

@interface OBRecommendation (Testing)

+ (instancetype)contentWithPayload:(NSDictionary *)payload;

@end

@interface OutbrainManager (Testing)

-(NSDictionary *) prepareLoadProductParams:(OBRecommendation * _Nonnull)rec;

@end


@interface SkAdNetworkAppInstallRecTests : XCTestCase

@property (nonatomic, strong) OBRecommendation *rec;

@end

@implementation SkAdNetworkAppInstallRecTests

NSString * const SK_ATTRIBUTION_SIGNATURE = @"MDUCGG6IpdcS+8/XTe9TM0/j3JWJ0ajzefVVfgIZAKo/92CtCPcyxjJz9DqSfm3TSTgHVk0gAg==";
NSString * const SK_NETWORK_ID = @"97r2b46745.skadnetwork";
NSString * const SK_ITUNES_ID = @"866450515";
NSString * const SK_NONCE = @"feb35745-f54f-416f-b961-6b79c749507c";
NSString * const SK_SIG_VERSION = @"2.0";
NSInteger const SK_SOURCE_APP_ID = 331786748;
long const SK_TIMESTAMP = 1601792957748;
long const SK_CAMPAIGN_ID = 33;



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
    
    XCTAssertTrue(self.rec.isAppInstall);
    XCTAssert([self.rec.skAdNetworkData.adNetworkId isEqualToString: SK_NETWORK_ID]);
    XCTAssert([self.rec.skAdNetworkData.campaignId intValue] == SK_CAMPAIGN_ID);
    XCTAssert(self.rec.skAdNetworkData.timestamp == SK_TIMESTAMP);
    XCTAssert([self.rec.skAdNetworkData.iTunesItemId isEqualToString: SK_ITUNES_ID]);
    XCTAssert([self.rec.skAdNetworkData.nonce isEqualToString: SK_NONCE]);
    XCTAssert([self.rec.skAdNetworkData.signature isEqualToString: SK_ATTRIBUTION_SIGNATURE]);
    XCTAssert([self.rec.skAdNetworkData.skNetworkVersion isEqualToString: SK_SIG_VERSION]);
    XCTAssert([self.rec.skAdNetworkData.sourceAppId intValue] == 331786748);
}

- (void) testPrepareLoadProductParams {
    NSDictionary *productParameters = [[OutbrainManager sharedInstance] prepareLoadProductParams: self.rec];
    XCTAssertNotNil(productParameters);
    if (@available(iOS 11.3, *)) {
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterITunesItemIdentifier] isEqualToString: SK_ITUNES_ID]);
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkIdentifier] isEqualToString: SK_NETWORK_ID]);
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkAttributionSignature] isEqualToString: SK_ATTRIBUTION_SIGNATURE]);
        NSString *nonceUUIDString = [[[productParameters objectForKey:SKStoreProductParameterAdNetworkNonce] UUIDString] lowercaseString];
        XCTAssert([nonceUUIDString isEqualToString: SK_NONCE]);
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkTimestamp] longValue] == SK_TIMESTAMP);
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkCampaignIdentifier] intValue] == SK_CAMPAIGN_ID);
    }
    if (@available(iOS 14.0, *)) {
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkVersion] isEqualToString: SK_SIG_VERSION]);
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier]  isKindOfClass:[NSNumber class]]);
        XCTAssert([[productParameters objectForKey:SKStoreProductParameterAdNetworkSourceAppStoreIdentifier] intValue] == SK_SOURCE_APP_ID);
    }
}



@end
