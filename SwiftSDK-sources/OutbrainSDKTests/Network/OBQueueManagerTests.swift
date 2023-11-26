//
//  OBQueueManagerTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest
@testable import OutbrainSDK
class OBQueueManagerTests: XCTestCase {
    
    var queueManager: OBQueueManager!
    
    override func setUp() {
        super.setUp()
        queueManager = OBQueueManager.shared
    }
    
    override func tearDown() {
        queueManager = nil
        super.tearDown()
    }
    
    func testSharedInstance() {
        let sharedInstance = OBQueueManager.shared
        XCTAssertNotNil(sharedInstance)
        XCTAssertTrue(sharedInstance === queueManager)
    }
    
    func testOperationCount_InitiallyZero() {
        let operationCount = queueManager.operationCount
        XCTAssertEqual(operationCount, 0)
    }
    
    func testEnqueueFetchRecsRequest() {
        let expectation = XCTestExpectation(description: "Fetch task executed")
        var isFetchTaskExecuted = false
        
        queueManager.enqueueFetchRecsRequest {
            isFetchTaskExecuted = true
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(isFetchTaskExecuted)
        XCTAssertEqual(queueManager.operationCount, 0)
    }
    
    func testEnqueueFetchRecsRequest_MultipleTasks() {
        let expectation = XCTestExpectation(description: "Fetch tasks executed")
        let taskCount = 3
        var executedTaskCount = 0
        
        for _ in 1...taskCount {
            queueManager.enqueueFetchRecsRequest {
                executedTaskCount += 1
                if executedTaskCount == taskCount {
                    expectation.fulfill()
                }
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(executedTaskCount, taskCount)
    }
    
}
