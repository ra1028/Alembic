import Foundation
import XCTest
@testable import Alembic

class SerializeTest: XCTestCase {
    let string = serializeTestJsonString
    let data = serializeTestJsonData
    
    func testSerializeString() {
        let json = JSON(string: string)
        
        do {
            let i: Int = try json.value(for: "key1")
            let s: String = try json.value(for: "key2")
            
            XCTAssertEqual(i, 100)
            XCTAssertEqual(s, "ABC")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testSerializeData() {
        let json = JSON(data: data)
        
        do {
            let i: Int = try json.value(for: "key1")
            let s: String = try json.value(for: "key2")
            
            XCTAssertEqual(i, 100)
            XCTAssertEqual(s, "ABC")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testFailedToSerializeString() {
        let json = JSON(string: "")
        
        do {
            _ = try json.value(for: "key1") as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.serializeFailed(with: with) {
            XCTAssertEqual(with as? String, "")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testFailedToSerializeData() {
        let json = JSON(data: .init())
        
        do {
            _ = try json.value(for: "key1") as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.serializeFailed(with: with) {
            XCTAssertEqual(with as? Data, Data())
        } catch let e {
            XCTFail("\(e)")
        }
    }
}

#if os(Linux)
extension SerializeTest {
    static var allTests: [(String, (SerializeTest) -> () throws -> Void)] {
        return [
            ("testSerializeString", testSerializeString),
            ("testSerializeData", testSerializeData),
            ("testFailedToSerializeString", testFailedToSerializeString),
            ("testFailedToSerializeData", testFailedToSerializeData),
        ]
    }
}
#endif
