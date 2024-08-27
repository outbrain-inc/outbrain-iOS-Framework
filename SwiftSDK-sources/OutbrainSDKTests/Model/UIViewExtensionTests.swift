//
//  UIViewExtensionTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 05/07/2023.
//

import XCTest
@testable import OutbrainSDK
final class UIViewExtensionTests: XCTestCase {
    
    func testPercentVisible() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        let view = UIView(frame: CGRect(x: 100, y: 100, width: 200, height: 200))
        window.addSubview(view)
        
        // Ensure that the view is fully visible
        XCTAssertEqual(view.percentVisible(), 1.0)
        
        // Move the view outside the window bounds
        view.frame.origin.x = 500
        
        // Ensure that the view is not visible at all
        XCTAssertEqual(view.percentVisible(), 0.0)
        
        // Move the view partially outside the window bounds
        view.frame.origin.x = 220
        
        // Ensure that the view is partially visible
        XCTAssertEqual(view.percentVisible(), 0.5)
    }
    
}
