//
//  OBResponseTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest

@testable import OutbrainSDK
final class OBResponseTests: XCTestCase {
    
    func testInit() {
        // Given
        let request: [String: Any] = ["param1": 1, "param2": "value"]
        let settings: [String: Any] = ["setting1": true, "setting2": 10]
        let viewabilityActions = OBViewabilityActions(reportServed: "https://example.com/click", reportViewed: "https://example.com/view1")
        let recommendations: [OBRecommendation] = [
            OBRecommendation(url: "https://example.com/article1"),
            OBRecommendation(url: "https://example.com/article2")
        ]
        let error = NSError(domain: "com.example.error", code: 500, userInfo: nil)
        
        // When
        let response = OBResponse(request: request, settings: settings, viewabilityActions: viewabilityActions, recommendations: recommendations, error: error)
        
        // Then
        XCTAssertEqual(response.request as NSDictionary, request as NSDictionary)
        XCTAssertEqual(response.settings as NSDictionary, settings as NSDictionary)
        XCTAssertEqual(response.error as NSError?, error)
        
        // Compare viewabilityActions
        XCTAssertEqual(response.viewabilityActions.clickUrl, viewabilityActions.clickUrl)
        XCTAssertEqual(response.viewabilityActions.viewUrls, viewabilityActions.viewUrls)
        
        // Compare recommendations
        XCTAssertEqual(response.recommendations.count, recommendations.count)
        for (index, recommendation) in response.recommendations.enumerated() {
            XCTAssertEqual(recommendation.url, recommendations[index].url)
            XCTAssertEqual(recommendation.origUrl, recommendations[index].origUrl)
            XCTAssertEqual(recommendation.content, recommendations[index].content)
            XCTAssertEqual(recommendation.source, recommendations[index].source)
            XCTAssertEqual(recommendation.image?.imageUrl, recommendations[index].image?.imageUrl)
            XCTAssertEqual(recommendation.position, recommendations[index].position)
            XCTAssertEqual(recommendation.author, recommendations[index].author)
            XCTAssertEqual(recommendation.publishDate, recommendations[index].publishDate)
            XCTAssertEqual(recommendation.sameSource, recommendations[index].sameSource)
            XCTAssertEqual(recommendation.disclosure?.imageUrl, recommendations[index].disclosure?.imageUrl)
            XCTAssertEqual(recommendation.disclosure?.clickUrl, recommendations[index].disclosure?.clickUrl)
            XCTAssertEqual(recommendation.pixels, recommendations[index].pixels)
            XCTAssertEqual(recommendation.reqId, recommendations[index].reqId)
        }
    }
}
