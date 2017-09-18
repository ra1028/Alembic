import Foundation
import XCTest
@testable import Alembic

final class DecodeTest: XCTestCase {
    private let valueJson: JSON = [
        "value": "value",
        "key": ["nested": "value"]
    ]
    private let arrayJson: JSON = ["array": ["A", "B", "C", "D", "E"]]
    private let dictionaryJson: JSON = ["dictionary": ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4]]
    
    func testDecodeValue() {
        measure {
            do {
                let value: String = try self.valueJson.decode(for: "value").value()
                XCTAssertEqual(value, "value")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodeOptionValue() {
        measure {
            do {
                let existing: String? = try self.valueJson.decode(for: "value").option()
                XCTAssertEqual(existing, "value")
                
                let missing: String? = try self.valueJson.decode(for: "missing").option()
                XCTAssertNil(missing)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodeArray() {
        measure {
            do {
                let array: [String] = try self.arrayJson.decode(for: "array").value()
                XCTAssertEqual(array, ["A", "B", "C", "D", "E"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodeOptionArray() {
        measure {
            do {
                let existing: [String]? = try self.arrayJson.decode(for: "array").option()
                XCTAssert(existing.map { $0 == ["A", "B", "C", "D", "E"] } ?? false)
                
                let missing: [String]? = try self.arrayJson.decode(for: "missing").option()
                XCTAssertNil(missing)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testParsedictionary() {
        measure {
            do {
                let dictionary: [String: Int] = try self.dictionaryJson.decode(for: "dictionary").value()
                XCTAssertEqual(dictionary, ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodeOptionDictionary() {
        measure {
            do {
                let existing: [String: Int]? = try self.dictionaryJson.decode(for: "dictionary").option()
                XCTAssert(existing.map { $0 == ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4] } ?? false)
                
                let missing: [String: Int]? = try self.dictionaryJson.decode(for: "missing").option()
                XCTAssertNil(missing)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

extension DecodeTest {
    static var allTests: [(String, (DecodeTest) -> () throws -> Void)] {
        return [
            ("testDecodeValue", testDecodeValue),
            ("testDecodeOptionValue", testDecodeOptionValue),
            ("testDecodeArray", testDecodeArray),
            ("testDecodeOptionArray", testDecodeOptionArray),
            ("testParsedictionary", testParsedictionary),
            ("testDecodeOptionDictionary", testDecodeOptionDictionary)
        ]
    }
}
