import XCTest
@testable import OutbrainSDK


class MockSFWidgetDelegate: SFWidgetDelegate {
    var didChangeHeightCalled = false
    var onRecClickCalled = false
    
    func didChangeHeight(_ newHeight: CGFloat) {
        didChangeHeightCalled = true
    }
    
    func onRecClick(_ url: URL) {
        onRecClickCalled = true
    }
}


class UIViewControllerTransitionCoordinatorMock: NSObject, UIViewControllerTransitionCoordinator {
    
    var isAnimated: Bool
    var presentationStyle: UIModalPresentationStyle
    var initiallyInteractive: Bool
    var isInterruptible: Bool
    var isInteractive: Bool
    var isCancelled: Bool
    var transitionDuration: TimeInterval = 0.0
    var percentComplete: CGFloat = 0.0
    var completionVelocity: CGFloat
    var completionCurve: UIView.AnimationCurve
    var containerView: UIView
    var targetTransform: CGAffineTransform
    var completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)?
    
    
    override init() {
        isAnimated = false
        presentationStyle = UIModalPresentationStyle(rawValue: 1)!
        initiallyInteractive = false
        isInterruptible = false
        isInteractive = false
        isCancelled = false
        completionVelocity = 0.0
        completionCurve = .easeInOut
        containerView = UIView()
        targetTransform = CGAffineTransform()
    }
    
    
    func animateAlongsideTransition(in view: UIView?, animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
        return true
    }
    
    
    func notifyWhenInteractionEnds(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        return
    }
    
    
    func notifyWhenInteractionChanges(_ handler: @escaping (UIViewControllerTransitionCoordinatorContext) -> Void) {
        return
    }
    
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return UIViewController()
    }
    
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return UIView()
    }
    
    
    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContext) -> Void)?, completion: ((UIViewControllerTransitionCoordinatorContext) -> Void)? = nil) -> Bool {
        self.completion = completion
        return true
    }
}


class SFWidgetTests: XCTestCase {
    
    var sfWidget: SFWidget!
    var mockDelegate: MockSFWidgetDelegate!
    
    
    override func setUp() {
        super.setUp()
        sfWidget = SFWidget(frame: CGRect(x: 0, y: 0, width: 200, height: 150))
        mockDelegate = MockSFWidgetDelegate()
        sfWidget.delegate = mockDelegate
    }
    
    
    override func tearDown() {
        sfWidget = nil
        mockDelegate = nil
        super.tearDown()
    }
    
    
    func testConfigure() {
        sfWidget.configure(
            with: mockDelegate,
            url: "https://example.com",
            widgetId: "widgetId",
            installationKey: "installationKey"
        )
        
        XCTAssertEqual(sfWidget.url, "https://example.com")
        XCTAssertEqual(sfWidget.widgetId, "widgetId")
        XCTAssertEqual(sfWidget.installationKey, "installationKey")
    }
    
    
    func testMessageHeightChange() {
        sfWidget.messageHeightChange(100)
        
        XCTAssertEqual(sfWidget.currentHeight, 100)
        XCTAssertTrue(mockDelegate.didChangeHeightCalled)
    }
    
    
    func testOnRecClick() {
        let url = URL(string: "https://example.com")!
        sfWidget.onRecClick(url)
        
        XCTAssertTrue(mockDelegate.onRecClickCalled)
    }
    
    
    func testSetUserId() {
        sfWidget.setUserId("testUserId")
        // user is opted-out - userId will be nil
        // XCTAssertEqual(sfWidget.userId, "testUserId")
    }
    
    
    func testGetCurrentHeight() {
        sfWidget.messageHeightChange(100)
        XCTAssertEqual(sfWidget.currentHeight, 100)
    }
    
    
    func testEnableEvents() {
        sfWidget.enableEvents()
        XCTAssertTrue(sfWidget.isWidgetEventsEnabled)
    }
    
    
    func testConfigureWithAdvancedSettings() {
        sfWidget.configure(
            with: mockDelegate,
            url: "https://example.com",
            widgetId: "widgetId",
            widgetIndex: 1,
            installationKey: "installationKey",
            userId: "userId",
            darkMode: true
        )
        
        XCTAssertEqual(sfWidget.url, "https://example.com")
        XCTAssertEqual(sfWidget.widgetId, "widgetId")
        XCTAssertEqual(sfWidget.installationKey, "installationKey")
        // user is opted-out - userId will be nil
        // XCTAssertEqual(sfWidget.userId, "userId")
        XCTAssertEqual(sfWidget.widgetIndex, 1)
        XCTAssertTrue(sfWidget.darkMode)
    }
    
    
    func testLoadMore() {
        sfWidget.configure(
            with: mockDelegate,
            url: "https://example.com",
            widgetId: "widgetId",
            installationKey: "installationKey"
        )
        
        sfWidget.loadMore()
        
        XCTAssertTrue(sfWidget.isLoading)
    }
    
    
    func testWillDisplayTableCell() {
        let cell = SFWidgetTableCell()
        sfWidget.willDisplay(cell)
        
        // Check if the SFWidget view is added to the cell's contentView
        XCTAssertTrue(cell.contentView.subviews.contains(sfWidget))
    }
    
    
    func testWillDisplayCollectionCell() {
        let cell = SFWidgetCollectionCell()
        sfWidget.willDisplay(cell)
        
        // Check if the SFWidget view is added to the cell's contentView
        XCTAssertTrue(cell.contentView.subviews.contains(sfWidget))
    }
    
    
    func testViewWillTransition() {
        let size = CGSize(width: 300, height: 300)
        let coordinator = UIViewControllerTransitionCoordinatorMock()
        
        sfWidget.viewWillTransition(to: size, with: coordinator)
        
        // Check if the inTransition property is set to true during the transition
        XCTAssertTrue(sfWidget.inTransition)
        
        // Run the completion block of the transition coordinator to simulate the end of the transition
        coordinator.completion?(coordinator)
        
        // Check if the inTransition property is set to false after the transition
        XCTAssertFalse(sfWidget.inTransition)
    }
}
