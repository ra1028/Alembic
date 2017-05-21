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
        do {
            let value: String = try valueJson.decode(for: "value").value()
            XCTAssertEqual(value, "value")
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodeOptionValue() {
        do {
            let optionValue: String? = try valueJson.decode(for: "value").option()
            XCTAssertEqual(optionValue, "value")
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodeMissingValue() {
        do {
            let optionValue: String? = try valueJson.decode(for: ["key", "missing"]).option()
            XCTAssertNil(optionValue)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodeArray() {
        do {
            let array: [String] = try arrayJson.decode(for: "array").value()
            XCTAssertEqual(array, ["A", "B", "C", "D", "E"])
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodeOptionArray() {
        do {
            let optionArray: [String]? = try arrayJson.decode(for: "array").option()
            XCTAssert(optionArray.map { $0 == ["A", "B", "C", "D", "E"] } ?? false)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodeDictionary() {
        do {
            let dictionary: [String: Int] = try dictionaryJson.decode(for: "dictionary").value()
            XCTAssertEqual(dictionary, ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodeOptionDictionary() {
        do {
            let optionDictionary: [String: Int]? = try dictionaryJson.decode(for: "dictionary").option()
            XCTAssert(optionDictionary.map { $0 == ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4] } ?? false)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

extension DecodeTest {
    static var allTests: [(String, (DecodeTest) -> () throws -> Void)] {
        return [
            ("testDecodeValue", testDecodeValue),
            ("testDecodeOptionValue", testDecodeOptionValue),
            ("testDecodeMissingValue", testDecodeMissingValue),
            ("testDecodeArray", testDecodeArray),
            ("testDecodeValue", testDecodeValue),
            ("testDecodeDictionary", testDecodeDictionary),
            ("testDecodeOptionDictionary", testDecodeOptionDictionary)
        ]
    }
}
