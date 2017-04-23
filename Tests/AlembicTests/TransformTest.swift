import XCTest
@testable import Alembic

class TransformTest: XCTestCase {
    fileprivate struct TestError: Error {}
    
    let object = transformTestJSONObject
    
    func testTransform() {
        let j = JSON(object)
        
        do {
            let map: String = try (j <| "key")
                .map { "map_" + $0 }
            let flatMap: String = try (j <| ["nested", "nested_key"])(String.self)
                .flatMap { v in (j <| "key").map { "flatMap_" + $0 + "_with_" + v } }
            let flatMapOptional: String = try (j <| ["nested", "nested_key"])(String.self)
                .flatMap { $0 as String? }
            let flatMapError: String = try (j <| "missing_key")(String.self.self)
                .flatMapError { _ in SecureDistillate.value("flat_map_error") }
            let catchUp: String = (j <| "error")
                .catch("catch_return")
            
            XCTAssertEqual(map, "map_value")
            XCTAssertEqual(flatMap, "flatMap_value_with_nested_value")
            XCTAssertEqual(flatMapOptional, "nested_value")
            XCTAssertEqual(flatMapError, "flat_map_error")
            XCTAssertEqual(catchUp, "catch_return")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "key")(String.self).flatMap { _ in nil } as String
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "key").filter { $0 == "error" } as String
            
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <|? "null").filterNone() as String
        
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "missing_key").mapError { _ in TestError() } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else { XCTFail("\(e)") }
        }
    }
    
    func testSubscriptTransform() {
        let j = JSON(object)
        
        let map = j["key"].distil().map { "map_" + $0 }.catch("").value() as String
        
        XCTAssertEqual(map, "map_value")
        
        do {
            _ = try j["null"].option().filterNone() as String
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testCreateDistillate() {
        let j = JSON(object)
        let value = SecureDistillate.value("value")
        XCTAssertEqual(value.value(), "value")
        
        do {
            _ = try InsecureDistillate<String>.filter.value()
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try InsecureDistillate<String>.filter.value()
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try InsecureDistillate.error(TestError()).value() as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else { XCTFail("\(e)") }
        }
        
        do {
            _ = try (j <| "key")(String.self).flatMap { _ in InsecureDistillate.filter } as String
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "missing_key")(String.self).flatMapError { _ in InsecureDistillate.error(TestError()) } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else {
                XCTFail("\(e)")
            }
        }
    }
}

#if os(Linux)
extension TransformTest {
    static var allTests: [(String, (TransformTest) -> () throws -> Void)] {
        return [
            ("testTransform", testTransform),
            ("testSubscriptTransform", testSubscriptTransform),
            ("testCreateDistillate", testCreateDistillate),
        ]
    }
}
#endif
