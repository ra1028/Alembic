import Foundation
import XCTest
@testable import Alembic

final class ValueTest: XCTestCase {
    let object = valueTestJson
    
    func testValue() {
        let json = JSON(object)
        
        do {
            let string: String = try json.value(for: "string")
            let int: Int = try json.value(for: "int")
            let bool: Bool = try json.value(for: "bool")
            let array: [String] = try json.value(for: "array")
            let dictionary: [String: Int] = try json.value(for: "dictionary")
            let nestedValue: Int = try json.value(for: ["nested", "array", 2])
            let nestedArray: [Int] = try json.value(for: ["nested", "array"])
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(int, 777)
            XCTAssertEqual(bool, true)
            XCTAssertEqual(array, ["A", "B", "C"])
            XCTAssertEqual(dictionary, ["A": 1, "B": 2, "C": 3])
            XCTAssertEqual(nestedValue, 3)
            XCTAssertEqual(nestedArray, [1, 2, 3, 4, 5])
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testValueError() {
        let json = JSON(object)
        
        do {
            _ = try json.value(for: "missing_key") as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.missingPath(path) where path == "missing_key" {
            XCTAssert(true)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try json.value(for: "int_string") as Int
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.typeMismatch(expected: expected, actual: actual, path: path) {
            XCTAssert(expected == Int.self)
            XCTAssertEqual(actual as? String, "1")
            XCTAssertEqual(path, "int_string")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testClassMapping() {
        let json = JSON(object)
        
        do {
            let user: User = try json.value(for: "user")
            
            XCTAssertEqual(user.id, 100)
            XCTAssertEqual(user.name, "ra1028")
            XCTAssertEqual(user.weight, 132.28)
            XCTAssertEqual(user.gender, Gender.male)
            XCTAssertEqual(user.smoker, true)
            XCTAssertEqual(user.email, "r.fe51028.r@gmail.com")
            XCTAssertEqual(user.friends.count, 1)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testStructMapping() {
        do {
            let json = JSON(object)
            
            let numbers: Numbers = try json.value(for: "numbers")
            
            XCTAssertEqual(numbers.number, 1)
            XCTAssertEqual(numbers.int8, 2)
            XCTAssertEqual(numbers.uint8, 3)
            XCTAssertEqual(numbers.int16, 4)
            XCTAssertEqual(numbers.uint16, 5)
            XCTAssertEqual(numbers.int32, 6)
            XCTAssertEqual(numbers.uint32, 7)
            XCTAssertEqual(numbers.int64, 8)
            XCTAssertEqual(numbers.uint64, 9)
        } catch let e {
            XCTFail("\(e)")
        }
    }
}

#if os(Linux)
extension ValueTest {
    static var allTests: [(String, (ValueTest) -> () throws -> Void)] {
        return [
            ("testValue", testValue),
            ("testValueError", testValueError),
            ("testClassMapping", testClassMapping),
            ("testStructMapping", testStructMapping),
        ]
    }
}
#endif

private enum Gender: String, Decodable {
    case male
    case female
}

private final class User: Initializable {
    let id: Int
    let name: String
    let weight: Double
    let gender: Gender
    let smoker: Bool
    let email: String
    let friends: [User]
    
    required init(with json: JSON) throws {
        _ = try (
            id = json.value(for: "id"),
            name = json.value(for: "name"),
            weight = json.value(for: "weight"),
            gender = json.value(for: "gender"),
            smoker = json.value(for: "smoker"),
            email = json.value(for: ["contact", "email"]),
            friends = json.value(for: "friends")
        )
    }
}

private struct Numbers: Decodable {
    let number: NSNumber
    let int8: Int8
    let uint8: UInt8
    let int16: Int16
    let uint16: UInt16
    let int32: Int32
    let uint32: UInt32
    let int64: Int64
    let uint64: UInt64
    
    fileprivate static func value(from json: JSON) throws -> Numbers {
        return try Numbers(
            number: json.value(for: "number"),
            int8: json.value(for: "int8"),
            uint8: json.value(for: "uint8"),
            int16: json.value(for: "int16"),
            uint16: json.value(for: "uint16"),
            int32: json.value(for: "int32"),
            uint32: json.value(for: "uint32"),
            int64: json.value(for: "int64"),
            uint64: json.value(for: "uint64")
        )
    }
}
