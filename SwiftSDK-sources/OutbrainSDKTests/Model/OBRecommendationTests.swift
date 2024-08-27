//
//  OBRecommendationTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest
@testable import OutbrainSDK

final class OBRecommendationTests: XCTestCase {
    
    func testIsPaidLink() {
        let recommendation = OBRecommendation(url: "https://paid.outbrain.com/article")
        let isPaidLink = recommendation.isPaidLink
        XCTAssertTrue(isPaidLink)
    }
    
    func testIsRTB_WithDisclosure() {
        let disclosure = OBDisclosure(imageUrl: "https://example.com/disclosure.png", clickUrl: "https://example.com/disclosure-click")
        let recommendation = OBRecommendation(disclosure: disclosure)
        let isRTB = recommendation.isRTB
        XCTAssertTrue(isRTB)
    }
    
    func testIsRTB_WithoutDisclosure() {
        let recommendation = OBRecommendation()
        let isRTB = recommendation.isRTB
        XCTAssertFalse(isRTB)
    }
    
    func testShouldDisplayDisclosureIcon_WithDisclosure() {
        let disclosure = OBDisclosure(imageUrl: "https://example.com/disclosure.png", clickUrl: "https://example.com/disclosure-click")
        let recommendation = OBRecommendation(disclosure: disclosure)
        let shouldDisplayIcon = recommendation.shouldDisplayDisclosureIcon()
        XCTAssertTrue(shouldDisplayIcon)
    }
    
    func testShouldDisplayDisclosureIcon_WithoutDisclosure() {
        let recommendation = OBRecommendation()
        let shouldDisplayIcon = recommendation.shouldDisplayDisclosureIcon()
        XCTAssertFalse(shouldDisplayIcon)
    }
}
