//
//  OBParseODBTests.m
//  OutbrainSDK
//
//  Created by Oded Regev on 8/23/17.
//  Copyright © 2017 Outbrain. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"
#import "OBRecommendationRequestOperation.h"

@interface OBRecommendationRequestOperation (Testing)

- (OBRecommendationResponse *)createResponseWithDict:(NSDictionary *)responseDict withError:(NSError *)error;

@end


@interface OBParseODBTests : XCTestCase

@property (nonatomic, strong) OBRecommendationResponse *response;

@end

@implementation OBParseODBTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
    
    NSDictionary *responseJson = [OBTestUtils JSONFromFile: @"odb_normal_response"];
    XCTAssertNotNil(responseJson);
    OBRecommendationRequestOperation *operation = [[OBRecommendationRequestOperation alloc] init];
    self.response = [operation createResponseWithDict:responseJson withError:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParsingOfRecommendationsFromNormalResponse {
    XCTAssertEqual([self.response.recommendations count], 6);
    
    // Paid Rec
    OBRecommendation *rec = self.response.recommendations[1];
    
    XCTAssert([rec.content isEqualToString:@"Gamers around the world have been waiting for this game!"]);
    XCTAssert([rec.source isEqualToString:@"Forge Of Empires"]);
    XCTAssertEqual(rec.isVideo, NO);
    XCTAssertEqual(rec.isPaidLink, YES);
    
    NSURL *paidURL = [Outbrain getUrl:rec];
    XCTAssert([paidURL.absoluteString containsString:@"http://paid.outbrain.com/network/redir?p=88FvbgMwqZ3e0z9gUy-lAC3zzV-FgMpemRBaCbBwAJFmWt8HQz9_7cEiuna2p5rcLJmekW46Tq_fJs4y6ld8d_5tsyCumLxxhY_26WHdWSrpX2wHRmdue7Osdsbv862kGZ1dO_SrKCW2MrKF_Bo0v_TgnlALZRU6wdJ6muB0FRLGPNB849eRd2Zt1Ik3WIeFMqGs1kAliINYBXIvWZc4gm0L2o2Ipa7QHRWFjOD0xpAdeBciX6cqdTnWJkIS-gAetFoIujKB6GOAg_i2n_VTPtuwZiN2OlmbT0ITuLzILKJCETKU4sQpHbss8AHxRWtrB8tR0IIZdbkhI5J2fp3B2H997LIlT_8CCRXsrfQDJyLnp29hzlDW7LYrANABztucviGezfJGOvAlsRyIZKqGxaxO-CyF8aBjL-SMrTy0vPaJr9HidPb25bv1RLdLxmRZSpdrNswukfFC-DlS4s1FVBhc78lS3t63JY5E60UKEH8kbUMPtA77NTmandJp53bTBquRtOPVTd6lgEJdxDR-kKfHO2iOByAnw2u0ZjiXWx5oYo2N2djxaExSdvgDe5Ta3Gw7wr8oVmt7s_u8GPpPniJQ2WdWV0kEQqoR_cGlLf-cKbYZNDuQFME-sbhaHuNXhfXaIDv8oxpECCsSWDG9k2u05W78hIi8YWh--j6sACds3JcCQQsUiWTLd2JZBODPhu3ZtuinouGGK5M_kZaRvTNW3cq9H1yo2aLv4Oar2Ka_d5-9irSzWKdkV-S2aa_hYCmtx9mrReUuuoDpVQn-Gw&c=eb06826b&v=3"]);
    
    XCTAssert([rec.image.url.absoluteString isEqualToString:@"http://images.outbrain.com/v1/U0VmME5mZkVvMjJId2tGZ3BSNkd4dz09/eyJpdSI6IjY2NGZhZDBlOGNkMzExMzkzMWE2ZmJkMzQwNGZmOWNmYWFlMzIwN2UyYzRjNDhmMzViNmE1ODhlODE1ZWY2ODEiLCJ3IjoyMDAsImgiOjIwMCwiZCI6MS4wLCJjcyI6MCwiZiI6MH0%3D.webp"]);
    
    // Organic Rec
    rec = self.response.recommendations[3];
    
    XCTAssert([rec.content isEqualToString:@"Combating the Content Overload"]);
    XCTAssert([rec.source isEqualToString:@"Outbrain | Mobile Demo"]);
    XCTAssertEqual(rec.shouldDisplayDisclosureIcon, NO);
    XCTAssertEqual(rec.isVideo, NO);
    XCTAssertEqual(rec.isPaidLink, NO);
    
    NSURL *originalURL = [Outbrain getUrl:rec];
    XCTAssert([originalURL.absoluteString containsString:@"http://mobile-demo.outbrain.com/2014/01/26/combating-the-content-overload/"]);
    
    XCTAssert([rec.image.url.absoluteString isEqualToString:@"http://images.outbrain.com/Imaginarium/api/uuid/0b7181e69865b86c585ee8f8de33b511041effa59b8f5ba68887b3f691029883/200/200/1.0/webp"]);
    
}

- (void)testParsingOfSettingsFromNormalResponse {
    OBSettings *settings = self.response.settings;
    XCTAssertNotNil(settings);
    XCTAssertEqual(settings.apv, YES);
    XCTAssertEqual(settings.shouldShowCtaButton, YES);
    
    XCTAssert([settings.smartfeedShadowColor isEqualToString:@"#ffa500"]);
    XCTAssert([settings.paidLabelText isEqualToString:@"Sponsored"]);
    XCTAssert([settings.paidLabelTextColor isEqualToString:@"#ffffff"]);
    XCTAssert([settings.paidLabelBackgroundColor isEqualToString:@"#666666"]);
    
    XCTAssertEqual(settings.isSmartFeed, YES);
    XCTAssertEqual([settings.feedContentArray count], 2);
    XCTAssertEqual(settings.feedChunkSize, 3);
    XCTAssert([settings.feedContentArray[0] isEqualToString:@"SFD_VRS_1"]);
    XCTAssert([settings.feedContentArray[1] isEqualToString:@"SFD_SWP_1"]);
}

- (void)testRecommendationsPosition {
    NSArray *recs = self.response.recommendations;
    for (int i = 0; i < recs.count; i++) {
        OBRecommendation *rec = recs[i];
        NSString *position = [NSString stringWithFormat:@"%d", i];
        XCTAssert([rec.position isEqualToString:position]);
    }
}



@end
