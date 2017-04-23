import Foundation
import XCTest
@testable import Alembic

class DecodeTest: XCTestCase {
    let object = decodeTestJson
    
    func testDecode() {
        let json = JSON(object)
        
        do {
            let string: String = try *json.decode("string")
            let int: Int = try *json.decode("int")
            let double: Double = try *json.decode("double")
            let float: Float = try *json.decode("float")
            let bool: Bool = try *json.decode("bool")
            let array: [String] = try *json.decode("array")
            let dictionary: [String: Int] = try *json.decode("dictionary")
            let nestedValue: Int = try *json.decode(["nested", "array", 2])
            let nestedArray: [Int] = try *json.decode(["nested", "array"])
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(int, 777)
            XCTAssertEqual(double, 77.7)
            XCTAssertEqual(float, 77.7)
            XCTAssertEqual(bool, true)
            XCTAssertEqual(array, ["A", "B", "C"])
            XCTAssertEqual(dictionary, ["A": 1, "B": 2, "C": 3])
            XCTAssertEqual(nestedValue, 3)
            XCTAssertEqual(nestedArray, [1, 2, 3, 4, 5])
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testDecodeSubscript() {
        do {
            let json = JSON(object)
            
            let string: String = try *json["string"].decode()
            let array: [String] = try *json["array"].decode()
            let dictionary: [String: Int] = try *json["dictionary"].decode()
            let nestedValue: Int = try *json["nested", "array", 2].decode()
            let subscriptChain: Int = try *json["nested"]["array"][2].decode()
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(array, ["A", "B", "C"])
            XCTAssertEqual(dictionary, ["A": 1, "B": 2, "C": 3])
            XCTAssertEqual(nestedValue, 3)
            XCTAssertEqual(subscriptChain, 3)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testDecodeError() {
        let json = JSON(object)
        
        do {
            _ = try *json.decode("missing_key") as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.missingPath(path) where path == "missing_key" {
            XCTAssert(true)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decode("int_string") as Int
            
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
            let user: User = try *json.decode("user")
            
            XCTAssertEqual(user.id, 100)
            XCTAssertEqual(user.name, "ra1028")
            XCTAssertEqual(user.weight, 132.28)
            XCTAssertEqual(user.gender, Gender.male)
            XCTAssertEqual(user.smoker, true)
            XCTAssertEqual(user.email, "r.fe51028.r@gmail.com")
            XCTAssertEqual(user.url.absoluteString, "https://github.com/ra1028")
            XCTAssertEqual(user.friends.count, 1)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testStructMapping() {
        do {
            let json = JSON(object)
            
            let numbers: Numbers = try *json.decode("numbers")
            
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
extension DistilTest {
    static var allTests: [(String, (DistilTest) -> () throws -> Void)] {
        return [
            ("testDistil", testDistil),
            ("testDistilSubscript", testDistilSubscript),
            ("testDistilHandler", testDistilHandler),
            ("testDecodeError", testDecodeError),
            ("testClassMapping", testClassMapping),
            ("testStructMapping", testStructMapping),
        ]
    }
}
#endif

extension URL: Decodable {
    public static func value(from json: JSON) throws -> URL {
        return try *json.decode().flatMap(self.init(string:))
    }
}

private enum Gender: String, Decodable {
    case male = "male"
    case female = "female"
}

private final class User: Initializable {
    let id: Int
    let name: String
    let weight: Double
    let gender: Gender
    let smoker: Bool
    let email: String
    let url: URL
    let friends: [User]
    
    required init(with json: JSON) throws {
        _ = try (
            id = *json.decode("id"),
            name = *json.decode("name"),
            weight = *json.decode("weight"),
            gender = *json.decode("gender"),
            smoker = *json.decode("smoker"),
            email = *json.decode(["contact", "email"]),
            url = *json.decode(["contact", "url"]),
            friends = *json.decode("friends")
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
            number: *json.decode("number"),
            int8: *json.decode("int8"),
            uint8: *json.decode("uint8"),
            int16: *json.decode("int16"),
            uint16: *json.decode("uint16"),
            int32: *json.decode("int32"),
            uint32: *json.decode("uint32"),
            int64: *json.decode("int64"),
            uint64: *json.decode("uint64")
        )
    }
}
