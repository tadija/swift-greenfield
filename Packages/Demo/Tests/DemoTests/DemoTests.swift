@testable import Demo
import XCTest

final class DemoTests: XCTestCase {

    func testCurrentContext() {
        let vm = DemoViewModel()
        let context = vm.currentContext
        XCTAssertEqual(context, "test")
    }

}
