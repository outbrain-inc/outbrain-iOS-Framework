//
//  OBViewTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 12/07/2023.
//

import XCTest
@testable import OutbrainSDK

final class OBViewTests: XCTestCase {

    func testIsTimerRunning() {
        let obView = OBView()
        XCTAssertTrue(obView.isTimerRunning(), "Viewability timer should be running initially")

        obView.viewVisibleTimer?.invalidate()
        XCTAssertFalse(obView.isTimerRunning(), "Viewability timer should not be running after invalidating it")
    }
    
    func testTrackViewability() {
        let obView = OBView()
        
        obView.trackViewability()
        
        XCTAssertNotNil(obView.viewVisibleTimer, "Viewability timer should not be nil after calling trackViewability()")
        XCTAssertTrue(obView.viewVisibleTimer!.isValid, "Viewability timer should be valid after calling trackViewability()")
    }
    
    func testCheckIfViewIsVisible_WhenLessThan50PercentVisible() {
        let obView = OBView()

        let superview = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        superview.addSubview(obView)

        let timer = Timer()
        obView.checkIfViewIsVisible(timer)

        let userInfo = timer.userInfo as? NSMutableDictionary
        XCTAssertNil(userInfo?["milisecondsVisible"], "milisecondsVisible should be reset when the view is less than 50% visible")
    }
    
    func testReportViewability() {
        let obView = OBView()
        obView.reportViewability(obView.viewVisibleTimer!)

        XCTAssertFalse(obView.isTimerRunning(), "Viewability timer should no be running after reporting viewability")
        XCTAssertNil(obView.superview, "View should be removed from its superview after reporting viewability")
    }
    
    func testRemoveFromSuperview() {
        let obView = OBView()
        obView.viewVisibleTimer = Timer()
        
        obView.removeFromSuperview()
        
        XCTAssertNil(obView.viewVisibleTimer, "Viewability timer should be stopped after removing from superview")
        XCTAssertNil(obView.superview, "View should be removed from its superview after calling removeFromSuperview()")
    }

}
