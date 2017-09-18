import Foundation
import XCTest
@testable import Alembic

final class ParseTest: XCTestCase {
    private let valueJson: JSON = [
        "value": "value",
        "key": ["nested": "value"]
    ]
    private let arrayJson: JSON = ["array": ["A", "B", "C", "D", "E"]]
    private let dictionaryJson: JSON = ["dictionary": ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4]]
    
    func testParseValue() {
        measure {
            do {
                let value: String = try self.valueJson.parse(for: "value").value()
                XCTAssertEqual(value, "value")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testParseOptionValue() {
        measure {
            do {
                let existing: String? = try self.valueJson.parse(for: "value").option()
                XCTAssertEqual(existing, "value")
                
                let missing: String? = try self.valueJson.parse(for: "missing").option()
                XCTAssertNil(missing)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testParseArray() {
        measure {
            do {
                let array: [String] = try self.arrayJson.parse(for: "array").value()
                XCTAssertEqual(array, ["A", "B", "C", "D", "E"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testParseOptionArray() {
        measure {
            do {
                let existing: [String]? = try self.arrayJson.parse(for: "array").option()
                XCTAssert(existing.map { $0 == ["A", "B", "C", "D", "E"] } ?? false)
                
                let missing: [String]? = try self.arrayJson.parse(for: "missing").option()
                XCTAssertNil(missing)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testParsedictionary() {
        measure {
            do {
                let dictionary: [String: Int] = try self.dictionaryJson.parse(for: "dictionary").value()
                XCTAssertEqual(dictionary, ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testParseOptionDictionary() {
        measure {
            do {
                let existing: [String: Int]? = try self.dictionaryJson.parse(for: "dictionary").option()
                XCTAssert(existing.map { $0 == ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4] } ?? false)
                
                let missing: [String: Int]? = try self.dictionaryJson.parse(for: "missing").option()
                XCTAssertNil(missing)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

extension ParseTest {
    static var allTests: [(String, (ParseTest) -> () throws -> Void)] {
        return [
            ("testParseValue", testParseValue),
            ("testParseOptionValue", testParseOptionValue),
            ("testParseArray", testParseArray),
            ("testParseOptionArray", testParseOptionArray),
            ("testParsedictionary", testParsedictionary),
            ("testParseOptionDictionary", testParseOptionDictionary)
        ]
    }
}
