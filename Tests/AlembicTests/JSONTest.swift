import Foundation
import XCTest
@testable import Alembic

final class JSONTest: XCTestCase {
    private let jsonString = "{\"key\": \"value\"}"
    private lazy var jsonData: Data = self.jsonString.data(using: .utf8)!
    
    func testInitializeFromAny() {
        measure {
            let json: JSON = ["key": "value"]
            XCTAssertEqual(json.rawValue, ["key": "value"])
        }
    }
    
    func testInitializeFromData() {
        measure {
            do {
                let json = try JSON(data: self.jsonData)
                XCTAssertEqual(json.rawValue, ["key": "value"])
            } catch let error {
                XCTFail("error: \(error)")
            }
        }
    }
    
    func testInitializeFromString() {
        measure {
            do {
                let json = try JSON(string: self.jsonString)
                XCTAssertEqual(json.rawValue, ["key": "value"])
            } catch let error {
                XCTFail("error: \(error)")
            }
        }
    }
}

private func XCTAssertEqual<T, U: Equatable>(_ expression1: Any, _ expression2: [T : U], file: StaticString = #file, line: UInt = #line) {
    let equal = (expression1 as? [T: U]).map { $0 == expression2 } ?? false
    XCTAssert(equal, file: file, line: line)
}

extension JSONTest {
    static var allTests: [(String, (JSONTest) -> () throws -> Void)] {
        return [
            ("testInitializeFromAny", testInitializeFromAny),
            ("testInitializeFromData", testInitializeFromData),
            ("testInitializeFromString", testInitializeFromString)
        ]
    }
}
