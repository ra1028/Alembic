import Foundation
import XCTest
@testable import Alembic

final class ErrorTest: XCTestCase {
    func testMissing() {
        struct Test: Parsable {
            let missing: String
            
            static func value(from json: JSON) throws -> Test {
                return try .init(missing: json.value(for: "missing"))
            }
        }
        
        let json: JSON = ["test": [:]]
        
        measure {
            do {
                _ = try json.value(for: "missing") as String
                XCTFail("Expect to throw error")
            } catch let JSON.Error.missing(path: path) {
                XCTAssertEqual(path, "missing")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.option(for: "test") as Test?
                XCTFail("Expect to throw error")
            } catch let JSON.Error.missing(path: path) {
                XCTAssertEqual(path, ["test", "missing"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.decode(for: "test").option() as Test?
                XCTFail("Expect to throw error")
            } catch let JSON.Error.missing(path: path) {
                XCTAssertEqual(path, ["test", "missing"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testTypeMismatch() {
        let json: JSON = ["int": 100]
        
        measure {
            do {
                _ = try json.value(for: "int") as String
                XCTFail("Expect to throw error")
            } catch let JSON.Error.typeMismatch(expected: expected, actualValue: actualValue, path: path) {
                XCTAssert(expected == String.self)
                XCTAssertEqual(actualValue as? Int, 100)
                XCTAssertEqual(path, "int")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.option(for: "int") as String?
                XCTFail("Expect to throw error")
            } catch let JSON.Error.typeMismatch(expected: expected, actualValue: actualValue, path: path) {
                XCTAssert(expected == String.self)
                XCTAssertEqual(actualValue as? Int, 100)
                XCTAssertEqual(path, "int")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
                
            }
        }
    }
    
    func testUnexpected() {
        let json: JSON = ["key": "value"]
        
        measure {
            do {
                _ = try json.decode(for: "key").filter { $0 == "filter" }.value() as String
                XCTFail("Expect to throw error")
            } catch let JSON.Error.unexpected(value: value, path: path) {
                XCTAssertEqual(value as? String, "value")
                XCTAssertEqual(path, "key")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.decode(for: "key").flatMap { (_: String) -> String? in nil }.value()
                XCTFail("Expect to throw error")
            } catch let JSON.Error.unexpected(value: value, path: path) {
                XCTAssertNil(value)
                XCTAssertEqual(path, "key")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.decode(for: "key").map { (_: String) -> String? in nil }.filterNil().value()
                XCTFail("Expect to throw error")
            } catch let JSON.Error.unexpected(value: value, path: path) {
                XCTAssertNil(value)
                XCTAssertEqual(path, "key")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testSerializeFailed() {
        let jsonString = "Invalid JSON string"
        let jsonData = jsonString.data(using: .utf8)!
        
        measure {
            do {
                _ = try JSON(data: jsonData)
                XCTFail("Expect to throw error")
            } catch let JSON.Error.serializeFailed(value: value) {
                XCTAssertEqual(value as? Data, jsonData)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try JSON(string: jsonString)
                XCTFail("Expect to throw error")
            } catch let JSON.Error.serializeFailed(value: value) {
                XCTAssertEqual(value as? String, jsonString)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testCustom() {
        struct Test: Parsable {
            static func value(from json: JSON) throws -> Test {
                throw JSON.Error.custom(reason: "Custom error")
            }
        }
        
        let json: JSON = ["key": "value"]
        
        measure {
            do {
                _ = try json.value(for: "key") as Test
                XCTFail("Expect to throw error")
            } catch let JSON.Error.custom(reason: reason) {
                XCTAssertEqual(reason, "Custom error")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.decode(for: "missing").mapError { _ in JSON.Error.custom(reason: "Custom error") }.value() as String
                XCTFail("Expect to throw error")
            } catch let JSON.Error.custom(reason: reason) {
                XCTAssertEqual(reason, "Custom error")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.decode(for: "missing").flatMapError { _ in .error(JSON.Error.custom(reason: "Custom error")) }.value() as String
                XCTFail("Expect to throw error")
            } catch let JSON.Error.custom(reason: reason) {
                XCTAssertEqual(reason, "Custom error")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testAssociatedPath() {
        struct Missing: Parsable {
            let value: String
            
            static func value(from json: JSON) throws -> Missing {
                return try .init(value: json.value(for: "missing"))
            }
        }
        
        struct TypeMismatch: Parsable {
            let value: String
            
            static func value(from json: JSON) throws -> TypeMismatch {
                return try .init(value: json.value(for: "typeMismatch"))
            }
        }
        
        struct Unexpected: Parsable {
            let value: String
            
            static func value(from json: JSON) throws -> Unexpected {
                return try .init(value: json.decode(for: "unexpected").filter { _ in false }.value())
            }
        }
        
        let json: JSON = ["test": ["typeMismatch": 100, "unexpected": "value"]]
        
        measure {
            do {
                _ = try json.value(for: "test") as Missing
            } catch let JSON.Error.missing(path: path) {
                XCTAssert(path == ["test", "missing"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.value(for: "test") as TypeMismatch
            } catch let JSON.Error.typeMismatch(expected: _, actualValue: _, path: path) {
                XCTAssert(path == ["test", "typeMismatch"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
            
            do {
                _ = try json.value(for: "test") as Unexpected
            } catch let JSON.Error.unexpected(value: _, path: path) {
                XCTAssert(path == ["test", "unexpected"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

extension ErrorTest {
    static var allTests: [(String, (ErrorTest) -> () throws -> Void)] {
        return [
            ("testMissing", testCustom),
            ("testTypeMismatch", testTypeMismatch),
            ("testUnexpected", testUnexpected),
            ("testSerializeFailed", testSerializeFailed),
            ("testCustom", testCustom),
            ("testAssociatedPath", testAssociatedPath)
        ]
    }
}
