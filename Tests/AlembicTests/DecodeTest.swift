import XCTest
@testable import Alembic

final class DecodeTest: XCTestCase {
    fileprivate struct Error: Swift.Error {}
    
    let object = decodeTestJson
    
    func testDecode() {
        let json = JSON(object)
        
        do {
            let map: String = try *json.decodeValue(for: "key")
                .map { "map_" + $0 }
            let flatMap: String = try *json.decodeValue(for: ["nested", "nested_key"])
                .flatMap { v in json.decodeValue(for: "key").map { "flatMap_" + $0 + "_with_" + v } }
            let flatMapOptional: String = try *json.decodeValue(for: ["nested", "nested_key"], as: String.self)
                .flatMap { $0 as String? }
            let flatMapError: String = try *json.decodeValue(for: "missing_key")
                .flatMapError { _ in Decoded.value("flat_map_error") }
            let `catch`: String = *json.decodeValue(for: "error")
                .catch("catch")
            
            XCTAssertEqual(map, "map_value")
            XCTAssertEqual(flatMap, "flatMap_value_with_nested_value")
            XCTAssertEqual(flatMapOptional, "nested_value")
            XCTAssertEqual(flatMapError, "flat_map_error")
            XCTAssertEqual(`catch`, "catch")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decodeValue(for: "key", as: String.self).flatMap { _ in nil } as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decodeValue(for: "key").filter { $0 == "error" } as String
            
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decodeOption(for: "null").filterNil() as String
        
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decodeValue(for: "missing_key").mapError { _ in Error() } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is Error = e {} else { XCTFail("\(e)") }
        }
    }
    
    func testCreateDecoded() {
        let json = JSON(object)
        let value = Decoded.value("value")
        XCTAssertEqual(*value, "value")
        
        do {
            _ = try *ThrowableDecoded<String>.filter
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *ThrowableDecoded<String>.filter
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *ThrowableDecoded<String>.error(Error())
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is Error = e {} else { XCTFail("\(e)") }
        }
        
        do {
            _ = try *json.decodeValue(for: "key", as: String.self).flatMap { _ in ThrowableDecoded.filter } as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decodeValue(for: "missing_key").flatMapError { _ in ThrowableDecoded.error(Error()) } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is Error = e {} else {
                XCTFail("\(e)")
            }
        }
    }
}

extension DecodeTest {
    static var allTests: [(String, (DecodeTest) -> () throws -> Void)] {
        return [
            ("testDecode", testDecode),
            ("testCreateDecoded", testCreateDecoded),
        ]
    }
}
