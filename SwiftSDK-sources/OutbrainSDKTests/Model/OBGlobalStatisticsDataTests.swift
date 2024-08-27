//
//  OBGlobalStatisticsDataTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest

@testable import OutbrainSDK
final class OBGlobalStatisticsDataTests: XCTestCase {
    
    func testInit() {
        let reportServedUrl = "https://example.com/report/served"
        let reportViewedUrl = "https://example.com/report/viewed"
        let rId = "request123"
        let requestStartDate = Date()
        let optedOut = true
        
        let statisticsData = OBGlobalStatisticsData(reportServedUrl: reportServedUrl, reportViewedUrl: reportViewedUrl, rId: rId, requestStartDate: requestStartDate, optedOut: optedOut)
        
        XCTAssertEqual(statisticsData.reportServedUrl, reportServedUrl)
        XCTAssertEqual(statisticsData.reportViewedUrl, reportViewedUrl)
        XCTAssertEqual(statisticsData.rId, rId)
        XCTAssertEqual(statisticsData.requestStartDate, requestStartDate)
        XCTAssertEqual(statisticsData.optedOut, optedOut)
    }
    
    func testInit_WithDefaultValues() {
        let statisticsData = OBGlobalStatisticsData()
        
        XCTAssertNil(statisticsData.reportServedUrl)
        XCTAssertNil(statisticsData.reportViewedUrl)
        XCTAssertNil(statisticsData.rId)
        XCTAssertNil(statisticsData.requestStartDate)
        XCTAssertNil(statisticsData.optedOut)
    }
}
