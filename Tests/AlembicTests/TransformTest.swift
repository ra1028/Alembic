import XCTest
@testable import Alembic

class TransformTest: XCTestCase {
    fileprivate struct TestError: Error {}
    
    let object = transformTestJSONObject
    
    func testTransform() {
        let json = JSON(object)
        
        do {
            let map: String = try *json.distil("key")
                .map { "map_" + $0 }
            let flatMap: String = try *json.distil(["nested", "nested_key"])
                .flatMap { v in json.distil("key").map { "flatMap_" + $0 + "_with_" + v } }
            let flatMapOptional: String = try *json.distil(["nested", "nested_key"], as: String.self)
                .flatMap { $0 as String? }
            let flatMapError: String = try *json.distil("missing_key")
                .flatMapError { _ in Decoded.value("flat_map_error") }
            let catchUp: String = *json.distil("error")
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
            _ = try *json.distil("key", as: String.self).flatMap { _ in nil } as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.distil("key").filter { $0 == "error" } as String
            
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.option("null").filterNone() as String
        
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.distil("missing_key").mapError { _ in TestError() } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else { XCTFail("\(e)") }
        }
    }
    
    func testSubscriptTransform() {
        let json = JSON(object)
        
        let map = *json["key"].distil().map { "map_" + $0 }.catch("") as String
        
        XCTAssertEqual(map, "map_value")
        
        do {
            _ = try *json["null"].option().filterNone() as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testCreateDistillate() {
        let json = JSON(object)
        let value = Decoded.value("value")
        XCTAssertEqual(*value, "value")
        
        do {
            _ = try *InDecoded<String>.filter
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *InDecoded<String>.filter
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *InDecoded<String>.error(TestError())
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else { XCTFail("\(e)") }
        }
        
        do {
            _ = try *json.distil("key", as: String.self).flatMap { _ in InDecoded.filter } as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.distil("missing_key").flatMapError { _ in InDecoded.error(TestError()) } as String
            
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
