import Foundation
import XCTest
@testable import Alembic

final class DecodedTest: XCTestCase {
    func testInitialize() {
        let valueDecoded: Decoded<String> = .value("value")
        XCTAssertEqual(valueDecoded.value(), "value")
    }
    
    func testTransform() {
        let decoded: Decoded<String> = .value("decoded")
        
        let map = decoded.map { $0 + "-map" }.value()
        let flatMap = decoded.flatMap { .value($0 + "-flatMap") }.value()
        
        XCTAssertEqual(map, "decoded-map")
        XCTAssertEqual(flatMap, "decoded-flatMap")
    }
}

extension DecodedTest {
    static var allTests: [(String, (DecodedTest) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testTransform", testTransform)
        ]
    }
}
