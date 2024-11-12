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
    var mockDelegate: MockDelegate? = nil

    
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
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("widgetmonitor.outbrain.com"))
    }
    
    
    func testFetchRecsDelegateSuccess() {
        // Given
        MockUrlProtocol.mockResponses = ["mv.outbrain.com": (Data.loadJSON(from: "odb_response_base"), HTTPURLResponse.valid(), nil)]
        sut = OBRequestHandler(OBRequest(url: "http://mobile-demo.outbrain.com", widgetID: "SDK_1"))
        let expectation = XCTestExpectation(description: "Fetch recs")
        mockDelegate = MockDelegate(expectation: expectation)
        
        
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
        mockDelegate = MockDelegate(expectation: expectation)
        
        
        // When
        sut?.fetchRecs(delegate: mockDelegate!)
        
        
        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNil(mockDelegate?.response)
        XCTAssertNotNil(mockDelegate?.error)
        XCTAssertTrue(mockDelegate?.error?.code == .network)
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
        XCTAssertTrue(MockUrlProtocol.calledHosts.contains("log.outbrainimg.com"))
    }
}



class MockUrlProtocol: URLProtocol {
    
    static var mockResponses: [String: (Data?, URLResponse?, Error?)] = [:]
    static var calledHosts: [String] = []
    
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url, let host = url.host else {
            return
        }
        
        
        MockUrlProtocol.calledHosts.append(host)
        
        // Retrieve the mock response
        if let (data, response, error) = MockUrlProtocol.mockResponses[host] {
            if let error = error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                if let response = response {
                    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                if let data = data {
                    client?.urlProtocol(self, didLoad: data)
                }
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    
    override func stopLoading() {
        
    }
}


class MockDelegate: OBResponseDelegate {
    
    let expectation: XCTestExpectation
    var response: OBRecommendationResponse?
    var error: OBError?
    
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    
    func outbrainDidReceiveResponse(withSuccess response: OBRecommendationResponse) {
        self.response = response
        self.expectation.fulfill()
    }
    
    func outbrainFailedToReceiveResposne(withError error: OBError?) {
        self.error = error
        self.expectation.fulfill()
    }
    
}


extension Data {
    
    static func loadJSON(from filename: String) -> Data? {
        
        guard let url = Bundle(for: OBRequestHandlerTests.self).url(forResource: filename, withExtension: "json") else {
            print("Failed to locate JSON file: \(filename).json")
            return nil
        }
        
        do {
            // Load the data from the file
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Failed to load JSON data: \(error.localizedDescription)")
            return nil
        }
    }
}


extension HTTPURLResponse {
    
    static func valid() -> HTTPURLResponse {
        return HTTPURLResponse(url: URL("https://mv.outbrain.com")!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil)!
    }
    
    static func invalid(code: Int) -> HTTPURLResponse {
        return HTTPURLResponse(url: URL("https://mv.outbrain.com")!,
                               statusCode: code,
                               httpVersion: nil,
                               headerFields: nil)!
    }
}
