import XCTest
@testable import Alembic

class OptionalTest: XCTestCase {
    let object = optionalTestJSONObject
    
    func testOptional() {
        let json = JSON(object)
        
        do {
            let string: String? = try *json.option("string")
            let int: Int? = try *json.option("int")
            let double: Double? = try *json.option("double")
            let float: Float? = try *json.option("float")
            let bool: Bool? = try *json.option("bool")
            let array: [String]? = try *json.option("array")
            let dictionary: [String: Int]? = try *json.option("dictionary")
            let nestedValue: Int? = try *json.option(["nested", "array", 2])
            let nestedArray: [Int]? = try *json.option(["nested", "array"])
            
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
            _ = try *json.distil("string") as Int?
            
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
        let json = JSON(object)
        
        do {
            let string: String? = try *json["string"].option()
            let bool: Bool? = try *json["bool"].option()
            let array: [String]? = try *json["array"].option()
            let dictionary: [String: Int]? = try *json["dictionary"].option()
            let nestedValue: Int? = try *json["nested", "array", 2].option()
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertNil(bool)
            XCTAssertNotNil(array)
            XCTAssertNotNil(dictionary)
            XCTAssertNil(nestedValue)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json["string"].option() as Int?
            
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
        let json = JSON(object)
        
        do {
            _ = try *json.distil("int") as String?
            
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
        let json = JSON(object)
        
        do {
            let user: User? = try *json.option("user1")
            
            XCTAssert(user == nil)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalMappingError() {
        let json = JSON(object)
        
        do {
            _ = try *json.distil("user2") as User?
            
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

private final class User: Initializable {
    let id: Int
    let name: String
    let email: String
    
    required init(with json: JSON) throws {
        _ = try (
            id = *json.distil("id"),
            name = *json.distil("name"),
            email = *json.distil(["contact", "email"])
        )
    }
}
