import Foundation
import XCTest
@testable import Alembic

final class OptionTest: XCTestCase {
    private let json: JSON = [
        "dictionary": ["key": "value"],
        "array": [0, 1, 2, 3, 4, 5]
    ]
    
    func testExistingValue() {
        do {
            let optionFromKeyPath: String? = try json.option(for: ["dictionary", "key"])
            XCTAssertEqual(optionFromKeyPath, "value")
            
            let optionFromIndexPath: Int? = try json.option(for: ["array", 0])
            XCTAssertEqual(optionFromIndexPath, 0)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testMissingValue() {
        do {
            let optionFromKeyPath: String? = try json.option(for: ["dictionary", "missing"])
            XCTAssertNil(optionFromKeyPath)
            
            let optionFromIndexPath: Int? = try json.option(for: ["array", 100])
            XCTAssertNil(optionFromIndexPath)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

extension OptionTest {
    static var allTests: [(String, (OptionTest) -> () throws -> Void)] {
        return [
            ("testExistingValue", testExistingValue),
            ("testMissingValue", testMissingValue)
        ]
    }
}
