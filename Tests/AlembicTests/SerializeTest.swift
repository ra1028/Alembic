import Foundation
import XCTest
@testable import Alembic

class SerializeTest: XCTestCase {
    let string = serializeTestJSONString
    let data = serializeTestJSONData
    
    func testSerializeString() {
        let j = JSON(string: string)
        
        do {
            let i: Int = try j <| "key1"
            let s: String = try j <| "key2"
            
            XCTAssertEqual(i, 100)
            XCTAssertEqual(s, "ABC")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testSerializeData() {
        let j = JSON(data: data)
        
        do {
            let i: Int = try j <| "key1"
            let s: String = try j <| "key2"
            
            XCTAssertEqual(i, 100)
            XCTAssertEqual(s, "ABC")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testFailedToSerializeString() {
        let j = JSON(string: "")
        
        do {
            _ = try j.distil("key1", as: String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.serializeFailed(with: with) {
            XCTAssertEqual(with as? String, "")
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testFailedToSerializeData() {
        let j = JSON(data: .init())
        
        do {
            _ = try j.distil("key1", as: String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.serializeFailed(with: with) {
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
