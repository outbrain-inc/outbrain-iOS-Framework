import XCTest
@testable import OutbrainSDK

class BridgeUrlBuilderTests: XCTestCase {
    
    var urlBuilder: BridgeUrlBuilder!
    
    
    override func setUp() {
        super.setUp()
        urlBuilder = BridgeUrlBuilder(
            url: "https://example.com",
            widgetId: "widgetId",
            installationKey: "installationKey"
        )
    }
    
    
    override func tearDown() {
        urlBuilder = nil
        super.tearDown()
    }
    
    
    func testAddUserId() {
        let userId = "userId"
        let url = urlBuilder.addUserId(userId: userId).build()
        
        XCTAssertTrue(url?.absoluteString.contains("userId=\(userId)") ?? false)
    }
    
    
    func testAddOSTracking() {
        let url = urlBuilder.addOSTracking().build()
        
        XCTAssertTrue(url?.absoluteString.contains("ostracking=false") ?? false)
    }
    
    
    func testAddWidgetIndex() {
        let index = 1
        let url = urlBuilder.addWidgetIndex(index: index).build()
        
        XCTAssertTrue(url?.absoluteString.contains("idx=\(index)") ?? false)
    }
    
    
    func testAddPermalink() {
        let permalink = "https://example.com/permalink"
        let url = urlBuilder.addPermalink(url: permalink).build()
        
        XCTAssertTrue(url?.absoluteString.contains("permalink=\(permalink)") ?? false)
    }
    
    
    func testAddTParam() {
        let tParam = "tParam"
        let url = urlBuilder.addTParam(tParamValue: tParam).build()
        
        XCTAssertTrue(url?.absoluteString.contains("t=\(tParam)") ?? false)
    }
    
    
    func testAddBridgeParams() {
        let bridgeParams = "bridgeParams"
        let url = urlBuilder.addBridgeParams(bridgeParams: bridgeParams).build()
        
        XCTAssertTrue(url?.absoluteString.contains("bridgeParams=\(bridgeParams)") ?? false)
    }
    
    
    func testAddDarkMode() {
        let url = urlBuilder.addDarkMode(isDarkMode: true).build()
        XCTAssertTrue(url?.absoluteString.contains("darkMode=true") ?? false)
    }
    
    
    func testAddEvents() {
        let url = urlBuilder.addEvents(widgetEvents: .all).build()
        XCTAssertTrue(url?.absoluteString.contains("widgetEvents=all") ?? false)
    }
    
    
    func testBuildPortalsUrls() {
        let url = "https://example.com/content"
        let builtUrl = urlBuilder.buildPlatformUrl(for: .content(url))
        
        XCTAssertTrue(builtUrl?.absoluteString.contains("contentUrl=\(url)") ?? false)
    }
}
