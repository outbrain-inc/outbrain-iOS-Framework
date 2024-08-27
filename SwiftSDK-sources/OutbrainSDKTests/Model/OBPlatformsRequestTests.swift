//
//  OBPlatformsRequestTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest

@testable import OutbrainSDK
final class OBPlatformsRequestTests: XCTestCase {
    
    func testInit() {
        let widgetId = "widget123"
        let widgetIndex = 0
        let contentUrl = "https://example.com/content"
        let portalUrl = "https://example.com/portal"
        let lang = "en"
        let psub = "sub123"
        
        let request = OBPlatformsRequest(widgetID: widgetId, widgetIndex: widgetIndex, contentUrl: contentUrl, portalUrl: portalUrl, lang: lang, psub: psub)
        
        XCTAssertEqual(request.url, nil)
        XCTAssertEqual(request.widgetId, widgetId)
        XCTAssertEqual(request.idx, "\(widgetIndex)")
        XCTAssertEqual(request.contentUrl, contentUrl)
        XCTAssertEqual(request.portalUrl, portalUrl)
        XCTAssertEqual(request.lang, lang)
        XCTAssertEqual(request.psub, psub)
    }
    
    func testIsValid() {
        let validRequest = OBPlatformsRequest(widgetID: "widget123", contentUrl: "https://example.com/content", lang: "en")
        let invalidRequest1 = OBPlatformsRequest(widgetID: "widget123", contentUrl: nil, lang: "en")
        let invalidRequest2 = OBPlatformsRequest(widgetID: "widget123", contentUrl: "https://example.com/content", lang: nil)
        let invalidRequest3 = OBPlatformsRequest(widgetID: "widget123", contentUrl: nil, lang: nil)
        
        XCTAssertTrue(validRequest.isValid)
        XCTAssertFalse(invalidRequest1.isValid)
        XCTAssertFalse(invalidRequest2.isValid)
        XCTAssertFalse(invalidRequest3.isValid)
    }
}
