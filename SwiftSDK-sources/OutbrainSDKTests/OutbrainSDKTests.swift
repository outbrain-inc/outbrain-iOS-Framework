//
//  OutbrainSDKTests.swift
//  OutbrainSDKTests
//
//  Created by oded regev on 28/05/2023.
//

import XCTest
@testable import OutbrainSDK

final class OutbrainSDKTests: XCTestCase {
    
    override func setUp() {
        Outbrain.WAS_INITIALIZED = false
        Outbrain.partnerKey = nil
    }
        
    func testInitializeOutbrain() {
        Outbrain.initializeOutbrain(withPartnerKey: "partnerKey")
        XCTAssertTrue(Outbrain.WAS_INITIALIZED)
        XCTAssertEqual(Outbrain.partnerKey, "partnerKey")
    }
    
    func testCheckInitiatedNotInitialized() {
        Outbrain.WAS_INITIALIZED = false
        let error = Outbrain.checkInitiated()

        switch error {
        case .genericError(let message, _, _),
             .networkError(let message, _, _),
             .nativeError(let message, _, _),
             .zeroRecommendationsError(let message, _, _):
            XCTAssertEqual(message, "Outbrain SDK hasn't initiated with a partner key")
        case .none:
            XCTAssertTrue(false)
        }
    }
    
    func testCheckInitiatedInitialized() {
        Outbrain.WAS_INITIALIZED = true
        let error = Outbrain.checkInitiated()

        XCTAssertNil(error)
    }
    
    func testFetchRecommendationsWithCallback() {
        let request = OBRequest(url: "https://example.com", widgetID: "AR_1")
        let expectation = XCTestExpectation(description: "Fetch recommendations callback called")
        
        Outbrain.fetchRecommendations(for: request) { response in
            XCTAssertNotNil(response)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }

    func testFetchRecommendationsWithDelegate_Success() {
        let request = OBRequest(url: "https://example.com", widgetID: "AR_1")
        let expectation = XCTestExpectation(description: "Fetch recommendations completion")
        let delegate = MockResponseDelegate(expectation: expectation)

        Outbrain.WAS_INITIALIZED = true
        
        Outbrain.fetchRecommendations(for: request, with: delegate)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertTrue(delegate.outbrainDidReceiveResponseCalled)
        XCTAssertNotNil(delegate.response)
    }
    
    func testGetUrl() {
        let recommendation = OBRecommendation(url: "https://example.com")
        let url = Outbrain.getUrl(recommendation)
        
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "https://example.com")
    }
    
    func testGetUrlWithPaidLink() {
        let recommendation = OBRecommendation(url: "https://paid.outbrain.com/123")
        let result = Outbrain.getUrl(recommendation)
        XCTAssertEqual(result, URL(string: "https://paid.outbrain.com/123"))
    }
    
    func testGetUrlWithOrganicLink() {
        let recommendation = OBRecommendation(url: "https://traffic.outbrain.com/123", origUrl: "https://example.com")
        let result = Outbrain.getUrl(recommendation)
        XCTAssertEqual(result, URL(string: "https://example.com"))
    }
    
    func testGetOutbrainAboutURL() {
        let url = Outbrain.getOutbrainAboutURL()
        
        XCTAssertNotNil(url)
        XCTAssertTrue(((url?.absoluteString.contains("https://www.outbrain.com/what-is/")) != nil))
    }
}


class MockResponseDelegate: OBResponseDelegate {
    var outbrainDidReceiveResponseCalled = false
    var response: OBRecommendationResponse?
    
    let expectation: XCTestExpectation

    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }

    func outbrainDidReceiveResponse(withSuccess response: OBRecommendationResponse) {
        outbrainDidReceiveResponseCalled = true
        self.response = response
        expectation.fulfill()
    }

    func reset() {
        outbrainDidReceiveResponseCalled = false
        response = nil
    }
}
