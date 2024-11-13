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
        Outbrain.isInitialized = false
        Outbrain.partnerKey = nil
    }
    
    override class func tearDown() {
        URLProtocol.unregisterClass(MockUrlProtocol.self)
        MockUrlProtocol.calledHosts.removeAll()
        MockUrlProtocol.mockResponses.removeAll()
        super.tearDown()
    }
    
    func testInitializeOutbrain() {
        Outbrain.initializeOutbrain(withPartnerKey: "partnerKey")
        XCTAssertTrue(Outbrain.isInitialized)
        XCTAssertEqual(Outbrain.partnerKey, "partnerKey")
    }
    
    func testCheckInitiatedNotInitialized() {
        Outbrain.isInitialized = false
        guard let error = Outbrain.checkInitiated() else {
            XCTAssertFalse(true)
            return
        }
        
        XCTAssertEqual(error.message, "Outbrain SDK hasn't initiated with a partner key")
    }
    
    func testCheckInitiatedInitialized() {
        Outbrain.isInitialized = true
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
        URLProtocol.registerClass(MockUrlProtocol.self)
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        
        let request = OBRequest(url: "https://example.com", widgetID: "AR_1")
        let expectation = XCTestExpectation(description: "Fetch recommendations completion")
        let delegate = MockResponseDelegate(expectation: expectation)

        Outbrain.isInitialized = true
        Outbrain.fetchRecommendations(for: request, with: delegate)

        wait(for: [expectation], timeout: 5.0)
        XCTAssertNotNil(delegate.response)
        XCTAssertFalse(delegate.response!.recommendations.isEmpty)
    }
    
    func testFetchRecsAsync() async throws {
        // Given
        URLProtocol.registerClass(MockUrlProtocol.self)
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        
        
        
        // When
        let response = try await Outbrain.fetchRecommendations(for: OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        
        //Then
        XCTAssertNotNil(response)
        XCTAssertFalse(response.isEmpty)
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("log.outbrainimg.com"))
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
