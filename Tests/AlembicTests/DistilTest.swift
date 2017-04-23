import Foundation
import XCTest
@testable import Alembic

class DistilTest: XCTestCase {
    let object = distilTestJSONObject
    
    func testDistil() {
        let j = JSON(object)
        
        do {
            let string: String = try *j.distil("string")
            let int: Int = try *j.distil("int")
            let double: Double = try *j.distil("double")
            let float: Float = try *j.distil("float")
            let bool: Bool = try *j.distil("bool")
            let array: [String] = try *j.distil("array")
            let dictionary: [String: Int] = try *j.distil("dictionary")
            let nestedValue: Int = try *j.distil(["nested", "array", 2])
            let nestedArray: [Int] = try *j.distil(["nested", "array"])
            
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
            let j = JSON(object)
            
            let string: String = try *j["string"].distil()
            let array: [String] = try *j["array"].distil()
            let dictionary: [String: Int] = try *j["dictionary"].distil()
            let nestedValue: Int = try *j["nested", "array", 2].distil()
            let subscriptChain: Int = try *j["nested"]["array"][2].distil()
            
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
        let j = JSON(object)
        
        do {
            _ = try *j.distil("missing_key") as String
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.missingPath(path) where path == "missing_key" {
            XCTAssert(true)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *j.distil("int_string") as Int
            
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
        let j = JSON(object)
        
        do {
            let user: User = try *j.distil("user")
            
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
            let j = JSON(object)
            
            let numbers: Numbers = try *j.distil("numbers")
            
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

extension URL: Distillable {
    public static func distil(json j: JSON) throws -> URL {
        return try *j.distil().flatMap(self.init(string:))
    }
}

private enum Gender: String, Distillable {
    case male = "male"
    case female = "female"
}

private final class User: Brewable {
    let id: Int
    let name: String
    let weight: Double
    let gender: Gender
    let smoker: Bool
    let email: String
    let url: URL
    let friends: [User]
    
    required init(json j: JSON) throws {
        _ = try (
            id = *j.distil("id"),
            name = *j.distil("name"),
            weight = *j.distil("weight"),
            gender = *j.distil("gender"),
            smoker = *j.distil("smoker"),
            email = *j.distil(["contact", "email"]),
            url = *j.distil(["contact", "url"]),
            friends = *j.distil("friends")
        )
    }
}

private struct Numbers: Distillable {
    let number: NSNumber
    let int8: Int8
    let uint8: UInt8
    let int16: Int16
    let uint16: UInt16
    let int32: Int32
    let uint32: UInt32
    let int64: Int64
    let uint64: UInt64
    
    fileprivate static func distil(json j: JSON) throws -> Numbers {
        return try Numbers(
            number: *j.distil("number"),
            int8: *j.distil("int8"),
            uint8: *j.distil("uint8"),
            int16: *j.distil("int16"),
            uint16: *j.distil("uint16"),
            int32: *j.distil("int32"),
            uint32: *j.distil("uint32"),
            int64: *j.distil("int64"),
            uint64: *j.distil("uint64")
        )
    }
}
