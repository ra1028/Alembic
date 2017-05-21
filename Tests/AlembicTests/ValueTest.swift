import Foundation
import XCTest
@testable import Alembic

final class ValueTest: XCTestCase {
    func testDefaultDecodableValues() {
        let json: JSON = [
            "String": "String",
            "Int": 100,
            "UInt": 100 as UInt,
            "Double": 100 as Double,
            "Float": 100 as Float,
            "Bool": true,
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
        
        measure {
            do {
                let string: String = try json.value(for: "String")
                XCTAssertEqual(string, "String")
                
                let int: Int = try json.value(for: "Int")
                XCTAssertEqual(int, 100)
                
                let uint: UInt = try json.value(for: "UInt")
                XCTAssertEqual(uint, 100)
                
                let double: Double = try json.value(for: "Double")
                XCTAssertEqual(double, 100)
                
                let float: Float = try json.value(for: "Float")
                XCTAssertEqual(float, 100)
                
                let bool: Bool = try json.value(for: "Bool")
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
    }
    
    func testNestedValue() {
        let json: JSON = ["key": ["nested": ["A", "B", "C"]]]
        
        measure {
            do {
                let value: String = try json.value(for: ["key", "nested", 0])
                XCTAssertEqual(value, "A")
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodableRawPresentable() {
        enum StringRawPresentable: String, Decodable {
            case test
        }
        
        enum IntRawPresentable: Int, Decodable {
            case test
        }
        
        let json: JSON = [
            "testString": "test",
            "testInt": 0
        ]
        
        measure {
            do {
                let stringRawPresentable: StringRawPresentable = try json.value(for: "testString")
                XCTAssertEqual(stringRawPresentable, StringRawPresentable.test)
                
                let intRawPresentable: IntRawPresentable = try json.value(for: "testInt")
                XCTAssertEqual(intRawPresentable, IntRawPresentable.test)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodableArray() {
        let json: JSON = ["stringArray": ["A", "B", "C", "D", "E"]]
        
        measure {
            do {
                let array: [String] = try json.value(for: "stringArray")
                XCTAssertEqual(array, ["A", "B", "C", "D", "E"])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
    
    func testDecodableDictionary() {
        let json: JSON = ["stringDictionary": ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4]]
        
        measure {
            do {
                let dictionary: [String: Int] = try json.value(for: "stringDictionary")
                XCTAssertEqual(dictionary, ["A": 0, "B": 1, "C": 2, "D": 3, "E": 4])
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
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
        
        let json: JSON = ["test": ["string": "string", "int": 100]]
        
        measure {
            do {
                let test: Test = try json.value(for: "test")
                XCTAssertEqual(test.string, "string")
                XCTAssertEqual(test.int, 100)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
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
        
        let json: JSON = ["test": ["string": "string", "int": 100]]
        
        measure {
            do {
                let test: Test = try json.value(for: "test")
                XCTAssertEqual(test.string, "string")
                XCTAssertEqual(test.int, 100)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
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
        
        let json: JSON = ["test": ["string": "string", "int": 100]]
        
        measure {
            do {
                let test: Test = try json.value(for: "test")
                XCTAssertEqual(test.string, "string")
                XCTAssertEqual(test.int, 100)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
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
        
        let json: JSON = ["test": ["string": "string", "int": 100]]
        
        measure {
            do {
                let test: Test = try json.value(for: "test")
                XCTAssertEqual(test.string, "string")
                XCTAssertEqual(test.int, 100)
            } catch let error {
                XCTFail("Unexpected error: \(error)")
            }
        }
    }
}

extension ValueTest {
    static var allTests: [(String, (ValueTest) -> () throws -> Void)] {
        return [
            ("testDefaultDecodableValues", testDefaultDecodableValues),
            ("testDecodableRawPresentable", testDecodableRawPresentable),
            ("testDecodableArray", testDecodableArray),
            ("testDecodableDictionary", testDecodableDictionary),
            ("testDecodableStruct", testDecodableStruct),
            ("testDecodableClass", testDecodableClass),
            ("testInitializableStruct", testInitializableStruct),
            ("testInitializableClass", testInitializableClass)
        ]
    }
}
