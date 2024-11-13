//
//  MockResponseDelegate.swift
//  OutbrainSDK
//
//  Created by Leonid Lemesev on 13/11/2024.
//


import XCTest
@testable import OutbrainSDK


class MockResponseDelegate: OBResponseDelegate {
    
    var response: OBRecommendationResponse?
    var error: OBError?
    
    let expectation: XCTestExpectation
    
    init(expectation: XCTestExpectation) {
        self.expectation = expectation
    }
    
    func outbrainDidReceiveResponse(withSuccess response: OBRecommendationResponse) {
        self.response = response
        expectation.fulfill()
    }
    
    func outbrainFailedToReceiveResposne(withError error: OBError?) {
        self.error = error
        expectation.fulfill()
    }
    
    func reset() {
        response = nil
    }
}
