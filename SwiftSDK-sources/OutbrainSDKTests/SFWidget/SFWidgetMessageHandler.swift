import XCTest
import WebKit
@testable import OutbrainSDK

class MockScriptMessage: WKScriptMessage {
    override var name: String {
        return "ReactNativeWebView"
    }
    
    override var body: Any {
        return "{\"height\": 100, \"sender\": \"resize\"}"
    }
}


class MockSFWidget: SFWidget {
    var messageHeightChangeCalled = false
    var messageHeight: CGFloat = 0.0

    override func messageHeightChange(_ height: CGFloat) {
        messageHeightChangeCalled = true
        messageHeight = height
    }
}


class SFWidgetMessageHandlerTests: XCTestCase {
    
    var messageHandler: SFWidgetMessageHandler!
    var userContentController: WKUserContentController!
    var message: WKScriptMessage!
    var mockSFWidget: MockSFWidget!
    
    override func setUp() {
        super.setUp()
        messageHandler = SFWidgetMessageHandler()
        userContentController = WKUserContentController()
        message = MockScriptMessage()
        mockSFWidget = MockSFWidget()
        messageHandler.delegate = mockSFWidget
    }
    
    override func tearDown() {
        messageHandler = nil
        userContentController = nil
        message = nil
        mockSFWidget = nil
        super.tearDown()
    }
    
    func testUserContentController() {
        messageHandler.userContentController(userContentController, didReceive: message)
        // Add your assertions here
        
        // Check that the delegate's messageHeightChange(_:) method was called
        XCTAssertTrue(mockSFWidget.messageHeightChangeCalled)
        
        // Check that the delegate's messageHeightChange(_:) method was called with the expected argument
        XCTAssertEqual(mockSFWidget.messageHeight, 100)
    }
    
}
