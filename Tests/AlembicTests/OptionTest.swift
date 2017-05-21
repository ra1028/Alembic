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
        do {
            let optionFromKeyPath: String? = try json.option(for: ["dictionary", "key"])
            XCTAssertEqual(optionFromKeyPath, "value")
            
            let optionFromIndexPath: Int? = try json.option(for: ["array", 0])
            XCTAssertEqual(optionFromIndexPath, 0)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExistingArray() {
        do {
            let optionArray: [Int]? = try json.option(for: "array")
            XCTAssert(optionArray.map { $0 == [0, 1, 2, 3, 4, 5] } ?? false)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testExistingDictionary() {
        do {
            let optionDictionary: [String: String]? = try json.option(for: "dictionary")
            XCTAssert(optionDictionary.map { $0 == ["key": "value"] } ?? false)
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
    
    func testMissingArray() {
        do {
            let optionArray: [Int]? = try json.option(for: "missing")
            XCTAssertNil(optionArray)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testMissingDictionary() {
        do {
            let optionDictionary: [String: String]? = try json.option(for: "missing")
            XCTAssertNil(optionDictionary)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testNull() {
        do {
            let null: String? = try json.option(for: "null")
            XCTAssertNil(null)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
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
