@testable import Demo
import XCTest

final class NetworkingTests: XCTestCase {

    func testLoad() async {
        let vm = NetworkingViewModel()
        XCTAssertEqual(vm.state.rows.count, 0)
        await vm.load()
        XCTAssertEqual(vm.state.rows.count, 3)
    }

}
