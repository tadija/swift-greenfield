@testable import Demo
import XCTest

final class TrendingTests: XCTestCase {

    func testLoad() async {
        let vm = TrendingViewModel()
        XCTAssertEqual(vm.state.rows.count, 0)
        await vm.load()
        XCTAssertEqual(vm.state.rows.count, 3)
    }

}
