import XCTest
@testable import BoringNotchBuildSupport

final class BuildSupportTests: XCTestCase {
    func testSwiftPMPlaceholderTargetIsAvailable() {
        XCTAssertNotNil(BoringNotchBuildSupport.self)
    }
}
