import Foundation
import XCTest
@testable import Alembic

final class ValueTest: XCTestCase {
    func testDefaultDecodableValues() {
        let object: [String: Any] = [
            "string": "string",
            "int": 100,
            "double": 100 as Double,
            "float": 100 as Float,
            "bool": true,
            "NSNumber": 100 as NSNumber,
            "Int8": 100 as NSNumber,
            "UInt8": 100 as NSNumber,
            "Int16": 100 as NSNumber,
            "UInt16": 100 as NSNumber,
            "Int32": 100 as NSNumber,
            "UInt32": 100 as NSNumber,
            "Int64": 100 as NSNumber,
            "UInt64": 100 as NSNumber
        ]
        
        let json = JSON(object)
        
        do {
            let string: String = try json.value(for: "string")
            XCTAssertEqual(string, "string")
            
            let int: Int = try json.value(for: "int")
            XCTAssertEqual(int, 100)
            
            let double: Double = try json.value(for: "double")
            XCTAssertEqual(double, 100)
            
            let float: Float = try json.value(for: "float")
            XCTAssertEqual(float, 100)
            
            let bool: Bool = try json.value(for: "bool")
            XCTAssertEqual(bool, true)
            
            let nsNumber: NSNumber = try json.value(for: "NSNumber")
            XCTAssertEqual(nsNumber, 100)
            
            let int8: Int8 = try json.value(for: "Int8")
            XCTAssertEqual(int8, 100)
            
            let uint8: UInt8 = try json.value(for: "UInt8")
            XCTAssertEqual(uint8, 100)
            
            let int16: Int16 = try json.value(for: "Int16")
            XCTAssertEqual(int16, 100)
            
            let uint16: UInt16 = try json.value(for: "UInt16")
            XCTAssertEqual(uint16, 100)
            
            let int32: Int32 = try json.value(for: "Int32")
            XCTAssertEqual(int32, 100)
            
            let uint32: UInt32 = try json.value(for: "UInt32")
            XCTAssertEqual(uint32, 100)
            
            let int64: Int64 = try json.value(for: "Int64")
            XCTAssertEqual(int64, 100)
            
            let uint64: UInt64 = try json.value(for: "UInt64")
            XCTAssertEqual(uint64, 100)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodableRawPresentable() {
        enum StringRawPresentable: String, Decodable {
            case test
        }
        
        enum IntRawPresentable: Int, Decodable {
            case test
        }
        
        let object: [String: Any] = [
            "testString": "test",
            "testInt": 0
        ]
        
        let json = JSON(object)
        
        do {
            let stringRawPresentable: StringRawPresentable = try json.value(for: "testString")
            XCTAssertEqual(stringRawPresentable, StringRawPresentable.test)
            
            let intRawPresentable: IntRawPresentable = try json.value(for: "testInt")
            XCTAssertEqual(intRawPresentable, IntRawPresentable.test)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodableArray() {
        let object: [String: Any] = [
            "stringArray": ["A", "B", "C", "D", "E"]
        ]
        
        let json = JSON(object)
        
        do {
            let array: [String] = try json.value(for: "stringArray")
            XCTAssertEqual(array, ["A", "B", "C", "D", "E"])
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodableDictionary() {
        let object: [String: Any] = [
            "stringDictionary": ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4]
        ]
        
        let json = JSON(object)
        
        do {
            let dictionary: [String: Int] = try json.value(for: "stringDictionary")
            XCTAssertEqual(dictionary, ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodableStruct() {
        struct Test: Decodable {
            let string: String
            let int: Int
            
            static func value(from json: JSON) throws -> Test {
                return try .init(
                string: json.value(for: "string"),
                int: json.value(for: "int")
                )
            }
        }
        
        let object: [String: Any] = [
            "test": ["string": "string", "int": 100]
        ]
        
        let json = JSON(object)
        
        do {
            let test: Test = try json.value(for: "test")
            XCTAssertEqual(test.string, "string")
            XCTAssertEqual(test.int, 100)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDecodableClass() {
        final class Test: Decodable {
            let string: String
            let int: Int
            
            private init(string: String, int: Int) {
                self.string = string
                self.int = int
            }
            
            static func value(from json: JSON) throws -> Test {
                return try .init(
                    string: json.value(for: "string"),
                    int: json.value(for: "int")
                )
            }
        }
        
        let object: [String: Any] = [
            "test": ["string": "string", "int": 100]
        ]
        
        let json = JSON(object)
        
        do {
            let test: Test = try json.value(for: "test")
            XCTAssertEqual(test.string, "string")
            XCTAssertEqual(test.int, 100)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testInitializableStruct() {
        struct Test: Initializable {
            let string: String
            let int: Int
            
            init(with json: JSON) throws {
                string = try json.value(for: "string")
                int = try json.value(for: "int")
            }
        }
        
        let object: [String: Any] = [
            "test": ["string": "string", "int": 100]
        ]
        
        let json = JSON(object)
        
        do {
            let test: Test = try json.value(for: "test")
            XCTAssertEqual(test.string, "string")
            XCTAssertEqual(test.int, 100)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testInitializableClass() {
        final class Test: Initializable {
            let string: String
            let int: Int
            
            init(with json: JSON) throws {
                string = try json.value(for: "string")
                int = try json.value(for: "int")
            }
        }
        
        let object: [String: Any] = [
            "test": ["string": "string", "int": 100]
        ]
        
        let json = JSON(object)
        
        do {
            let test: Test = try json.value(for: "test")
            XCTAssertEqual(test.string, "string")
            XCTAssertEqual(test.int, 100)
        } catch let error {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

extension ValueTest {
    static var allTests: [(String, (ValueTest) -> () throws -> Void)] {
        return [
        ]
    }
}
