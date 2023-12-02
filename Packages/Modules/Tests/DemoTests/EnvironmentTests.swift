@testable import Demo
import XCTest

final class EnvironmentTests: XCTestCase {

    func testCurrentContext() {
        let state = EnvironmentViewState()
        let context = state.contextDescription
        XCTAssertEqual(context, "test")
    }

}
