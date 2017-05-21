import Foundation
import XCTest
@testable import Alembic

final class DecodedTest: XCTestCase {
    func testInitialize() {
        measure {
            let valueDecoded = Decoded.value("value")
            XCTAssertEqual(valueDecoded.value(), "value")
        }
    }
    
    func testTransform() {
        measure {
            let decoded = Decoded.value("decoded")
            
            let map = decoded.map { $0 + "-map" }
            XCTAssertEqual(map.value(), "decoded-map")
            
            let flatMap = decoded.flatMap { .value($0 + "-flatMap") }
            XCTAssertEqual(flatMap.value(), "decoded-flatMap")
        }
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
