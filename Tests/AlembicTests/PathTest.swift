import Foundation
import XCTest
@testable import Alembic

final class PathTest: XCTestCase {
    func testPathElementEquatable() {
        measure {
            let keyPathElement: JSON.Path.Element = "key"
            let indexPathElement: JSON.Path.Element = 100
            
            XCTAssert(keyPathElement == "key")
            XCTAssert(indexPathElement == 100)
        }
    }
    
    func testPathEquatable() {
        measure {
            let singleKeyPath: JSON.Path = "key"
            let singleIndexPath: JSON.Path = 100
            
            let multiKeyPath: JSON.Path = ["key1", "key2", "key3"]
            let multiIndexPath: JSON.Path = [1, 2, 3]
            
            let mixedMultiPath: JSON.Path = ["key1", 1, "key2", 2]
            
            XCTAssert(singleKeyPath.elements == ["key"])
            XCTAssert(singleIndexPath.elements == [100])
            
            XCTAssert(multiKeyPath.elements == ["key1", "key2", "key3"])
            XCTAssert(multiIndexPath.elements == [1, 2, 3])
            
            XCTAssert(mixedMultiPath.elements == ["key1", 1, "key2", 2])
        }
    }
}

extension PathTest {
    static var allTests: [(String, (PathTest) -> () throws -> Void)] {
        return [
            ("testPathElementEquatable", testPathElementEquatable),
            ("testPathEquatable", testPathEquatable),
        ]
    }
}
