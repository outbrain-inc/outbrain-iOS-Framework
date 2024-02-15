import XCTest
@testable import OutbrainSDK

class GPPUtilsTests: XCTestCase {
    
    // This method is called before the invocation of each test method in the class
    override func setUp() {
        super.setUp()
        // Reset UserDefaults before each test
        GPPUtils.userDefaults.removeObject(forKey: IABGPP_HDR_SectionsKey)
        GPPUtils.userDefaults.removeObject(forKey: IABGPP_HDR_GppStringKey)
    }
    
    // This method is called after the invocation of each test method in the class
    override func tearDown() {
        // Clean up UserDefaults after each test
        GPPUtils.userDefaults.removeObject(forKey: IABGPP_HDR_SectionsKey)
        GPPUtils.userDefaults.removeObject(forKey: IABGPP_HDR_GppStringKey)
        super.tearDown()
    }
    
    // Test that gppSections returns the correct value when it is set
    func testGPPSectionsReturnsCorrectValue() {
        let testValue = "testSections"
        GPPUtils.userDefaults.set(testValue, forKey: IABGPP_HDR_SectionsKey)
        XCTAssertEqual(GPPUtils.gppSections, testValue)
    }
    
    // Test that gppString returns the correct value when it is set
    func testGPPStringReturnsCorrectValue() {
        let testValue = "testGppString"
        GPPUtils.userDefaults.set(testValue, forKey: IABGPP_HDR_GppStringKey)
        XCTAssertEqual(GPPUtils.gppString, testValue)
    }
    
    // Test that gppSections returns empty string as default registered value
    func testGPPSectionsReturnsEmptyStringAsDefault() {
        XCTAssertEqual(GPPUtils.gppSections, "")
    }
    
    // Test that gppString returns empty string as default registered value
    func testGPPStringReturnsEmptyStringAsDefault() {
        XCTAssertEqual(GPPUtils.gppString, "")
    }
    
}
