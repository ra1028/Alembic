import Foundation
import XCTest
@testable import Alembic

final class ErrorTest: XCTestCase {
    func testMissing() {
        struct Test: Decodable {
            let missing: String
            
            static func value(from json: JSON) throws -> Test {
                return try .init(missing: json.value(for: "missing"))
            }
        }
        
        let object: [String: Any] = ["test": [:]]
        let json = JSON(object)
        
        do {
            _ = try json.value(for: "missing") as String
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.missing(path: path) = error {
                XCTAssertEqual(path, "missing")
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.option(for: "test") as Test?
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.missing(path: path) = error {
                XCTAssertEqual(path, ["test", "missing"])
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.decode(for: "test").option() as Test?
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.missing(path: path) = error {
                XCTAssertEqual(path, ["test", "missing"])
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testTypeMismatch() {
        let object: [String: Any] = ["int": 100]
        let json = JSON(object)
        
        do {
            _ = try json.value(for: "int") as String
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.typeMismatch(expected: expected, actualValue: actualValue, path: path) = error {
                XCTAssert(expected == String.self)
                XCTAssertEqual(actualValue as? Int, 100)
                XCTAssertEqual(path, "int")
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.option(for: "int") as String?
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.typeMismatch(expected: expected, actualValue: actualValue, path: path) = error {
                XCTAssert(expected == String.self)
                XCTAssertEqual(actualValue as? Int, 100)
                XCTAssertEqual(path, "int")
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testFiltered() {
        let object: [String: Any] = ["key": "value"]
        let json = JSON(object)
        
        do {
            _ = try json.decode(for: "key").filter { $0 == "filter" }.value() as String
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.filtered(value: value, type: type) = error {
                XCTAssertEqual(value as? String, "value")
                XCTAssert(type == String.self)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.decode(for: "key").flatMap { (_: String) -> String? in nil }.value()
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.filtered(value: value, type: type) = error {
                XCTAssertNil(value)
                XCTAssert(type == String?.self)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.decode(for: "key").map { (_: String) -> String? in nil }.filterNil().value()
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.filtered(value: value, type: type) = error {
                XCTAssertNil(value)
                XCTAssert(type == String?.self)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testSerializeFailed() {
        let jsonString = "Invalid JSON string"
        let jsonData = jsonString.data(using: .utf8)!
        
        do {
            _ = try JSON(data: jsonData)
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.serializeFailed(value: value) = error {
                XCTAssertEqual(value as? Data, jsonData)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try JSON(string: jsonString)
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.serializeFailed(value: value) = error {
                XCTAssertEqual(value as? String, jsonString)
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testCustom() {
        struct Test: Decodable {
            static func value(from json: JSON) throws -> Test {
                throw JSON.Error.custom(reason: "Custom error")
            }
        }
        
        let object: [String: Any] = ["key": "value"]
        let json = JSON(object)
        
        do {
            _ = try json.value(for: "key") as Test
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.custom(reason: reason) = error {
                XCTAssertEqual(reason, "Custom error")
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.decode(for: "missing").mapError { _ in JSON.Error.custom(reason: "Custom error") }.value() as String
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.custom(reason: reason) = error {
                XCTAssertEqual(reason, "Custom error")
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
        
        do {
            _ = try json.decode(for: "missing").flatMapError { _ in .error(JSON.Error.custom(reason: "Custom error")) }.value() as String
            XCTFail("Expect to throw error")
        } catch let error {
            if case let JSON.Error.custom(reason: reason) = error {
                XCTAssertEqual(reason, "Custom error")
            } else {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

extension ErrorTest {
    static var allTests: [(String, (ErrorTest) -> () throws -> Void)] {
        return [
        ]
    }
}
