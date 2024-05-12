//
//  OBRequestTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest

@testable import OutbrainSDK
final class OBRequestTests: XCTestCase {
    
    func testInit() {
        let url = "https://example.com/recommendations"
        let widgetId = "widget123"
        let widgetIndex = 0
        let externalId = "external123"
        let startDate = Date()
        
        let request = OBRequest(url: url, widgetID: widgetId, widgetIndex: widgetIndex, externalID: externalId, startDate: startDate)
        
        XCTAssertEqual(request.url, url)
        XCTAssertEqual(request.widgetId, widgetId)
        XCTAssertEqual(request.idx, "\(widgetIndex)")
        XCTAssertEqual(request.externalID, externalId)
        XCTAssertEqual(request.startDate, startDate)
    }
    
    func testInit_WithDefaultValues() {
        let widgetId = "widget123"
        let request = OBRequest(url: nil, widgetID: widgetId)
        
        XCTAssertNil(request.url)
        XCTAssertEqual(request.widgetId, widgetId)
        XCTAssertEqual(request.idx, "0")
        XCTAssertNil(request.externalID)
        XCTAssertNil(request.startDate)
    }
}

