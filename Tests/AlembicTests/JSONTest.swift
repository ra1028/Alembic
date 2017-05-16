import Foundation
import XCTest
@testable import Alembic

final class JSONTest: XCTestCase {
    private let jsonString = "{\"key\": \"value\"}"
    private lazy var jsonData: Data = self.jsonString.data(using: .utf8)!
    
    func testInitializeFromAny() {
        let jsonObject: [String: Any] = ["key": "value"]
        let json = JSON(jsonObject)
        XCTAssertEqual(json.rawValue, ["key": "value"])
    }
    
    func testInitializeFromData() {
        do {
            let json = try JSON(data: jsonData)
            XCTAssertEqual(json.rawValue, ["key": "value"])
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
    
    func testInitializeFromString() {
        do {
            let json = try JSON(string: jsonString)
            XCTAssertEqual(json.rawValue, ["key": "value"])
        } catch let error {
            XCTFail("error: \(error)")
        }
    }
}

private func XCTAssertEqual<T: Hashable, U: Equatable>(_ expression1: Any, _ expression2: [T : U], file: StaticString = #file, line: UInt = #line) {
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
