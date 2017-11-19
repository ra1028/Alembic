import Foundation
import XCTest
@testable import Alembic

final class OptionTest: XCTestCase {
    private let json: JSON = [
        "array": [0, 1, 2, 3, 4, 5],
        "dictionary": ["key": "value"],
        "null": NSNull()
    ]
    
    func testExistingValue() {
        measure {
            do {
                let optionFromKeyPath: String? = try self.json.option(for: ["dictionary", "key"])
                XCTAssertEqual(optionFromKeyPath, "value")
                
                let optionFromIndexPath: Int? = try self.json.option(for: ["array", 0])
                XCTAssertEqual(optionFromIndexPath, 0)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testExistingArray() {
        measure {
            do {
                let optionArray: [Int]? = try self.json.option(for: "array")
                XCTAssert(optionArray.map { $0 == [0, 1, 2, 3, 4, 5] } ?? false)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testExistingDictionary() {
        measure {
            do {
                let optionDictionary: [String: String]? = try self.json.option(for: "dictionary")
                XCTAssert(optionDictionary.map { $0 == ["key": "value"] } ?? false)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testMissingValue() {
        measure {
            do {
                let optionFromKeyPath: String? = try self.json.option(for: ["dictionary", "missing"])
                XCTAssertNil(optionFromKeyPath)
                
                let optionFromIndexPath: Int? = try self.json.option(for: ["array", 100])
                XCTAssertNil(optionFromIndexPath)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testMissingArray() {
        measure {
            do {
                let optionArray: [Int]? = try self.json.option(for: "missing")
                XCTAssertNil(optionArray)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testMissingDictionary() {
        measure {
            do {
                let optionDictionary: [String: String]? = try self.json.option(for: "missing")
                XCTAssertNil(optionDictionary)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testNull() {
        measure {
            do {
                let null: String? = try self.json.option(for: "null")
                XCTAssertNil(null)
            } catch {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

extension OptionTest {
    static var allTests: [(String, (OptionTest) -> () throws -> Void)] {
        return [
            ("testExistingValue", testExistingValue),
            ("testExistingArray", testExistingArray),
            ("testExistingDictionary", testExistingDictionary),
            ("testMissingValue", testMissingValue),
            ("testMissingArray", testMissingArray),
            ("testMissingDictionary", testMissingDictionary),
            ("testNull", testNull)
        ]
    }
}
