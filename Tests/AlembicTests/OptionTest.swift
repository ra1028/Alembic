import XCTest
@testable import Alembic

class OptionTest: XCTestCase {
    let object = optionTestJson
    
    func testOption() {
        let json = JSON(object)
        
        do {
            let string: String? = try *json.decodeOption("string")
            let int: Int? = try *json.decodeOption("int")
            let double: Double? = try *json.decodeOption("double")
            let float: Float? = try *json.decodeOption("float")
            let bool: Bool? = try *json.decodeOption("bool")
            let array: [String]? = try *json.decodeOption("array")
            let dictionary: [String: Int]? = try *json.decodeOption("dictionary")
            let nestedValue: Int? = try *json.decodeOption(["nested", "array", 2])
            let nestedArray: [Int]? = try *json.decodeOption(["nested", "array"])
            
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
            _ = try *json.decode("string") as Int?
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.typeMismatch(expected: expected, actual: actual, path: path) {
            XCTAssert(expected == Int.self)
            XCTAssertEqual(actual as? String, "Alembic")
            XCTAssertEqual(path, "string")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionError() {
        let json = JSON(object)
        
        do {
            _ = try *json.decode("int") as String?
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.typeMismatch(expected: expected, actual: actual, path: path) {
            XCTAssert(expected == String.self)
            XCTAssertEqual(actual as? Int, 777)
            XCTAssertEqual(path, "int")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionMapping() {
        let json = JSON(object)
        
        do {
            let user: User? = try *json.decodeOption("user1")
            
            XCTAssert(user == nil)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionMappingError() {
        let json = JSON(object)
        
        do {
            _ = try *json.decode("user2") as User?
            
            XCTFail("Expected the error to occur")
        } catch let e {
            switch e {
            case let DecodeError.missingPath(path):
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
            id = *json.decode("id"),
            name = *json.decode("name"),
            email = *json.decode(["contact", "email"])
        )
    }
}
