import Foundation
import XCTest
@testable import Alembic

final class ParsedTest: XCTestCase {
    func testInitialize() {
        measure {
            let valueParsed = Parsed.value("value")
            XCTAssertEqual(valueParsed.value(), "value")
        }
    }
    
    func testTransform() {
        measure {
            let parsed = Parsed.value("Parsed")
            
            let map = parsed.map { $0 + "-map" }
            XCTAssertEqual(map.value(), "Parsed-map")
            
            let flatMap = parsed.flatMap { .value($0 + "-flatMap") }
            XCTAssertEqual(flatMap.value(), "Parsed-flatMap")
        }
    }
}

extension ParsedTest {
    static var allTests: [(String, (ParsedTest) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testTransform", testTransform)
        ]
    }
}
