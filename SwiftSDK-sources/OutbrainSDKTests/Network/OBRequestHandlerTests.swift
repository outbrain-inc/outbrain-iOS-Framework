//
//  OBRequestHandlerTests.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 11/11/2024.
//


import XCTest
@testable import OutbrainSDK
class OBRequestHandlerTests: XCTestCase {
    
    var sut: OBRequestHandler? = nil
    var obRequest: OBRequest? = nil
    var obResponseDelegate: OBResponseDelegate? = nil
    var mockDelegate: MockResponseDelegate? = nil

    
    override func setUp() {
        super.setUp()
        URLProtocol.registerClass(MockUrlProtocol.self)
    }
    
    
    override func tearDown() {
        URLProtocol.unregisterClass(MockUrlProtocol.self)
        MockUrlProtocol.calledHosts.removeAll()
        MockUrlProtocol.mockResponses.removeAll()
        super.tearDown()
    }
    
    
    func testFetchRecsCallbackSuccess() {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        let expectation = XCTestExpectation(description: "Fetch recs callback")
        var testResponse: OBRecommendationResponse? = nil
        
        
        // When
        sut?.fetchRecs(callback: { response in
            testResponse = response
            expectation.fulfill()
        })
        
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(testResponse)
        XCTAssertNil(testResponse?.error)
        XCTAssertFalse(testResponse!.recommendations.isEmpty)
    }
    
    
    func testFetchRecsCallbackFailure() {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (nil, URLResponse(), OBError.generic(message: "", code: .generic))]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        let expectation = XCTestExpectation(description: "Fetch recs")
        var testResponse: OBRecommendationResponse? = nil
        
        
        // When
        sut?.fetchRecs(callback: { response in
            testResponse = response
            expectation.fulfill()
        })
        
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(testResponse)
        XCTAssertNotNil(testResponse?.error)
        XCTAssertEqual(testResponse!.error!.code, .network)
        sleep(2)
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
    }
    
    
    func testFetchRecsDelegateSuccess() {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        let expectation = XCTestExpectation(description: "Fetch recs")
        mockDelegate = MockResponseDelegate(expectation: expectation)
        
        
        // When
        sut?.fetchRecs(delegate: mockDelegate!)
        
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(mockDelegate?.response)
        XCTAssertNil(mockDelegate?.response?.error)
        XCTAssertFalse(mockDelegate?.response?.recommendations.isEmpty == true)
    }
    
    
    func testFetchRecsDelegateFailure() {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (nil, URLResponse(), NSError(domain: "MockErrorDomain", code: 500, userInfo: [NSLocalizedDescriptionKey: "Mock server error"]))]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        let expectation = XCTestExpectation(description: "Fetch recs")
        mockDelegate = MockResponseDelegate(expectation: expectation)
        
        
        // When
        sut?.fetchRecs(delegate: mockDelegate!)
        
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(mockDelegate?.response)
        XCTAssertNotNil(mockDelegate?.error)
        XCTAssertTrue(mockDelegate?.error?.code == .network)
        sleep(1)
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
    }
    
    
    func testFetchRecsHttpError() async {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (nil, URLResponse(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        do {
            // When
            let _ = try await sut?.fetchRecsAsync()
        } catch {
            // Then
            sleep(1)
            XCTAssertNotNil(error)
            XCTAssert(error is OBError)
            XCTAssert((error as! OBError).code == .generic)
            XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
        }
    }
    
    
    func testFetchRecsInvalidParams() async {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (nil, HTTPURLResponse.invalid(code: 404), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        do {
            // When
            let _ = try await sut?.fetchRecsAsync()
        } catch {
            // Then
            sleep(1)
            XCTAssertNotNil(error)
            XCTAssert(error is OBError)
            XCTAssert((error as! OBError).code == .invalidParameters)
            XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
        }
    }
    
    
    func testFetchRecsServerError() async {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (nil, HTTPURLResponse.invalid(code: 505), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        do {
            // When
            let _ = try await sut?.fetchRecsAsync()
        } catch {
            // Then
            sleep(1)
            XCTAssertNotNil(error)
            XCTAssert(error is OBError)
            XCTAssert((error as! OBError).code == .server)
            XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
        }
    }
    
    
    func testFetchRecsDataEmpty() async {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (nil, HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        do {
            // When
            let _ = try await sut?.fetchRecsAsync()
        } catch {
            // Then
            sleep(1)
            XCTAssertNotNil(error)
            XCTAssert(error is OBError)
            XCTAssert((error as! OBError).type == .zeroRecommendations)
            XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
        }
    }
    
    
    func testFetchRecsParsingError() async {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_parsing_error"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        do {
            // When
            let _ = try await sut?.fetchRecsAsync()
        } catch {
            // Then
            sleep(1)
            XCTAssertNotNil(error)
            XCTAssert(error is OBError)
            XCTAssert((error as! OBError).type == .native)
            XCTAssert((error as! OBError).code == .parsing)
            XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
        }
    }
    
    
    func testFetchRecsZeroRecs() async {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_no_recs"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        do {
            // When
            let _ = try await sut?.fetchRecsAsync()
        } catch {
            // Then
            XCTAssertNotNil(error)
            XCTAssert(error is OBError)
            XCTAssert((error as! OBError).type == .zeroRecommendations)
            XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
        }
    }
    
    
    func testFetchRecsAsync() async throws {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        
        
        // When
        let response = try await sut?.fetchRecsAsync()
        
        
        //Then
        XCTAssertNotNil(response)
        XCTAssertNil(response!.error)
        sleep(2)
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("log.outbrainimg.com"))
    }
    
    
    func testPixelsFired() {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        let expectation = XCTestExpectation(description: "Fetch recs callback")
        var testResponse: OBRecommendationResponse? = nil
        
        
        // When
        sut?.fetchRecs(callback: { response in
            testResponse = response
            expectation.fulfill()
        })
        
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(testResponse)
        XCTAssertNil(testResponse?.error)
        XCTAssertFalse(testResponse!.recommendations.isEmpty)
        sleep(2)
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("log.outbrainimg.com"))
    }
}
