import XCTest
@testable import Alembic

class OptionalTest: XCTestCase {
    let object = optionalTestJSONObject
    
    func testOptional() {
        let j = JSON(object)
        
        do {
            let string: String? = try j.option("string").value()
            let int: Int? = try *j.option("int")
            let double: Double? = try *j.option("double")
            let float: Float? = try *j.option("float")
            let bool: Bool? = try *j.option("bool")
            let array: [String]? = try *j.option("array")
            let dictionary: [String: Int]? = try *j.option("dictionary")
            let nestedValue: Int? = try *j.option(["nested", "array", 2])
            let nestedArray: [Int]? = try *j.option(["nested", "array"])
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(int, 777)
            XCTAssertNil(double)
            XCTAssertEqual(float, 77.7)
            XCTAssertNil(bool)
            XCTAssertNotNil(array)
            XCTAssertNotNil(dictionary)
            XCTAssertNil(nestedValue)
            XCTAssertNil(nestedArray)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *j.distil("string") as Int?
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.typeMismatch(expected: expected, actual: actual, path: path) {
            XCTAssert(expected == Int.self)
            XCTAssertEqual(actual as? String, "Alembic")
            XCTAssertEqual(path, "string")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalSubscript() {
        let j = JSON(object)
        
        do {
            let string: String? = try *j["string"].option()
            let bool: Bool? = try *j["bool"].option()
            let array: [String]? = try *j["array"].option()
            let dictionary: [String: Int]? = try *j["dictionary"].option()
            let nestedValue: Int? = try *j["nested", "array", 2].option()
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertNil(bool)
            XCTAssertNotNil(array)
            XCTAssertNotNil(dictionary)
            XCTAssertNil(nestedValue)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *j["string"].option() as Int?
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.typeMismatch(expected: expected, actual: actual, path: path) {
            XCTAssert(expected == Int.self)
            XCTAssertEqual(actual as? String, "Alembic")
            XCTAssertEqual(path, "string")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalError() {
        let j = JSON(object)
        
        do {
            _ = try *j.distil("int") as String?
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.typeMismatch(expected: expected, actual: actual, path: path) {
            XCTAssert(expected == String.self)
            XCTAssertEqual(actual as? Int, 777)
            XCTAssertEqual(path, "int")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalMapping() {
        let j = JSON(object)
        
        do {
            let user: User? = try *j.option("user1")
            
            XCTAssert(user == nil)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalMappingError() {
        let j = JSON(object)
        
        do {
            _ = try *j.distil("user2") as User?
            
            XCTFail("Expected the error to occur")
        } catch let e {
            switch e {
            case let DistillError.missingPath(path):
                XCTAssert(path == ["user2", "contact", "email"])
            default:
                XCTFail("\(e)")
            }
        }
    }
}

#if os(Linux)
extension OptionalTest {
    static var allTests: [(String, (OptionalTest) -> () throws -> Void)] {
        return [
            ("testOptional", testOptional),
            ("testOptionalSubscript", testOptionalSubscript),
            ("testOptionalError", testOptionalError),
            ("testOptionalMapping", testOptionalMapping),
            ("testOptionalMappingError", testOptionalMappingError),
        ]
    }
}
#endif

private final class User: Brewable {
    let id: Int
    let name: String
    let email: String
    
    required init(json j: JSON) throws {
        _ = try (
            id = *j.distil("id"),
            name = *j.distil("name"),
            email = *j.distil(["contact", "email"])
        )
    }
}
