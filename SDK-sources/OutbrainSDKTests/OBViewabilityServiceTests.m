//
//  OBViewabilityServiceTests.m
//  OutbrainSDKTests
//
//  Created by Oded Regev on 14/07/2022.
//  Copyright © 2022 Outbrain. All rights reserved.
//


#import <XCTest/XCTest.h>
#import "OBTestUtils.h"
#import "OutbrainSDK.h"
#import "OBViewabilityService.h"
#import "OBViewabilityActions.h"


@class OBViewabilityService;
@interface OBViewabilityService (Testing)

-(NSURL *) viewabilityUrlWithMandatoryParams:(NSURLComponents *)components tmParam:(NSString *)tmParam isOptedOut:(BOOL)isOptedOut;

@end


@interface OBViewabilityServiceTests : XCTestCase


@end


@implementation OBViewabilityServiceTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [Outbrain initializeOutbrainWithPartnerKey:@"12345"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testViewabilityUrlWithManddatoryParams {
    OBViewabilityService *viewabilityService = [OBViewabilityService sharedInstance];
    NSDictionary *viewabilityActionsPayload = @{
        @"reportServed":@"https://log.outbrainimg.com/loggerServices/widgetGlobalEvent?rId=32d40614464564265b21db53298b382c&pvId=32d40614464564265b21db53298b382c&sid=5291479&pid=4737&idx=0&wId=220&pad=6&org=0&tm=0&eT=0",
            
        @"reportViewed":
            @"https://log.outbrainimg.com/loggerServices/widgetGlobalEvent?rId=32d40614464564265b21db53298b382c&pvId=32d40614464564265b21db53298b382c&sid=5291479&pid=4737&idx=0&wId=220&pad=6&org=0&tm=0&eT=3"};
    
    OBViewabilityActions *viewabilityActions = [[OBViewabilityActions alloc] initWithPayload:viewabilityActionsPayload];
    NSString *timeToProcessRequest = @"329";
    BOOL optedOut = YES;
    
    NSURLComponents *components = [NSURLComponents componentsWithString:viewabilityActions.reportServedUrl];
    NSURL *viewabilityUrl = [viewabilityService viewabilityUrlWithMandatoryParams:components tmParam:timeToProcessRequest isOptedOut:optedOut];
    
    XCTAssertNotNil(viewabilityUrl);
    XCTAssertTrue(viewabilityUrl.scheme && viewabilityUrl.host);
    XCTAssertTrue([viewabilityUrl.absoluteString containsString:@"tm=329"]);
    XCTAssertTrue([viewabilityUrl.absoluteString containsString:@"oo=true"]);
    
    NSURLComponents *componentsResult = [[NSURLComponents alloc] initWithString:viewabilityUrl.absoluteString];
    NSMutableArray *resultQueryItems = [componentsResult.queryItems mutableCopy];

    [resultQueryItems filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSURLQueryItem *queryItem = (NSURLQueryItem *)evaluatedObject;
        return [queryItem.name isEqualToString:@"tm"] || [queryItem.name isEqualToString:@"oo"];
    }]];
    
    XCTAssertTrue(resultQueryItems.count == 2);
}

@end
