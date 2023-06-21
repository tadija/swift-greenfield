import XCTest

final class AppUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        app = XCUIApplication()
        app.configureLaunchArguments()
        app.launch()

        continueAfterFailure = false
    }

    func testExample() throws {
        XCTAssertFalse(app.staticTexts["test"].exists)
    }

}

extension XCUIApplication {
    func configureLaunchArguments() {
        launchArguments.append("UITests")
    }
}
