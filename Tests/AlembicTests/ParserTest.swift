import Foundation
import XCTest
@testable import Alembic

final class ParserTest: XCTestCase {
    func testInitialize() {
        let parser = Parser.value("value")
        XCTAssertEqual(parser.value(), "value")
    }
    
    func testTransform() {
        let parser = Parser.value("value")
        
        let map = parser.map { $0 + "-map" }
        XCTAssertEqual(map.value(), "value-map")
        
        let flatMap = parser.flatMap { .value($0 + "-flatMap") }
        XCTAssertEqual(flatMap.value(), "value-flatMap")
    }
}

extension ParserTest {
    static var allTests: [(String, (ParserTest) -> () throws -> Void)] {
        return [
            ("testInitialize", testInitialize),
            ("testTransform", testTransform)
        ]
    }
}
