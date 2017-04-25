import XCTest
@testable import Alembic

final class OptionTest: XCTestCase {
    let object = optionTestJson
    
    func testOption() {
        let json = JSON(object)
        
        do {
            let string: String? = try json.option(for: "string")
            let int: Int? = try json.option(for: "int")
            let bool: Bool? = try json.option(for: "bool")
            let array: [String]? = try json.option(for: "array")
            let dictionary: [String: Int]? = try json.option(for: "dictionary")
            let nestedValue: Int? = try json.option(for: ["nested", "array", 2])
            let nestedArray: [Int]? = try json.option(for: ["nested", "array"])
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(int, 777)
            XCTAssertNil(bool)
            XCTAssertNotNil(array)
            XCTAssertNotNil(dictionary)
            XCTAssertNil(nestedValue)
            XCTAssertNil(nestedArray)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try json.option(for: "string") as Int?
            
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
            _ = try json.option(for: "int") as String?
            
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
            let user: User? = try json.option(for: "user1")
            
            XCTAssert(user == nil)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionMappingError() {
        let json = JSON(object)
        
        do {
            _ = try json.option(for: "user2") as User?
            
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
extension OptionTest {
    static var allTests: [(String, (OptionTest) -> () throws -> Void)] {
        return [
            ("testOption", testOption),
            ("testOptionError", testOptionError),
            ("testOptionMapping", testOptionMapping),
            ("testOptionMappingError", testOptionMappingError),
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
            id = json.value(for: "id"),
            name = json.value(for: "name"),
            email = json.value(for: ["contact", "email"])
        )
    }
}
