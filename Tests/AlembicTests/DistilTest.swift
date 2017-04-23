import Foundation
import XCTest
@testable import Alembic

class DistilTest: XCTestCase {
    let object = distilTestJSONObject
    
    func testDistil() {
        let json = JSON(object)
        
        do {
            let string: String = try *json.distil("string")
            let int: Int = try *json.distil("int")
            let double: Double = try *json.distil("double")
            let float: Float = try *json.distil("float")
            let bool: Bool = try *json.distil("bool")
            let array: [String] = try *json.distil("array")
            let dictionary: [String: Int] = try *json.distil("dictionary")
            let nestedValue: Int = try *json.distil(["nested", "array", 2])
            let nestedArray: [Int] = try *json.distil(["nested", "array"])
            
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
    
    func testDistilSubscript() {
        do {
            let json = JSON(object)
            
            let string: String = try *json["string"].distil()
            let array: [String] = try *json["array"].distil()
            let dictionary: [String: Int] = try *json["dictionary"].distil()
            let nestedValue: Int = try *json["nested", "array", 2].distil()
            let subscriptChain: Int = try *json["nested"]["array"][2].distil()
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(array, ["A", "B", "C"])
            XCTAssertEqual(dictionary, ["A": 1, "B": 2, "C": 3])
            XCTAssertEqual(nestedValue, 3)
            XCTAssertEqual(subscriptChain, 3)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testDistillError() {
        let json = JSON(object)
        
        do {
            _ = try *json.distil("missing_key") as String
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.missingPath(path) where path == "missing_key" {
            XCTAssert(true)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.distil("int_string") as Int
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.typeMismatch(expected: expected, actual: actual, path: path) {
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
            let user: User = try *json.distil("user")
            
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
            
            let numbers: Numbers = try *json.distil("numbers")
            
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
            ("testDistillError", testDistillError),
            ("testClassMapping", testClassMapping),
            ("testStructMapping", testStructMapping),
        ]
    }
}
#endif

extension URL: Decodable {
    public static func value(from json: JSON) throws -> URL {
        return try *json.distil().flatMap(self.init(string:))
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
            id = *json.distil("id"),
            name = *json.distil("name"),
            weight = *json.distil("weight"),
            gender = *json.distil("gender"),
            smoker = *json.distil("smoker"),
            email = *json.distil(["contact", "email"]),
            url = *json.distil(["contact", "url"]),
            friends = *json.distil("friends")
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
            number: *json.distil("number"),
            int8: *json.distil("int8"),
            uint8: *json.distil("uint8"),
            int16: *json.distil("int16"),
            uint16: *json.distil("uint16"),
            int32: *json.distil("int32"),
            uint32: *json.distil("uint32"),
            int64: *json.distil("int64"),
            uint64: *json.distil("uint64")
        )
    }
}
