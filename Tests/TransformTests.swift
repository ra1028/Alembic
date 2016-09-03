//
//  TransformTests.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
@testable import Alembic

class TransformTests: XCTestCase {
    fileprivate struct TestError: Error {}
    
    let object = TestJSON.transform.object
    
    func testTransform() {
        let j = JSON(object)
        
        do {
            let map: String = try (j <| "key")
                .map { "map_" + $0 }
            let flatMap: String = try (j <| ["nested", "nested_key"])(String.self)
                .flatMap { v -> Distillate<String> in (j <| "key").map { "flatMap_" + $0 + "_with_" + v } }
            let flatMapOptional: String = try (j <| ["nested", "nested_key"])(String.self)
                .flatMap { Optional<String>.some($0) }
            let flatMapError: String = try (j <| "missing_key")(String.self.self)
                .flatMapError { _ in .just("flat_map_error") }
            let catchUp: String = (j <| "error")
                .catch("catch_return")
            let replaceNil: String = try (j <|? "null")
                .replaceNil("replace_nil")
            let replaceEmpty: [String] = try (j <| "array")
                .replaceEmpty(["replace_empty"])
            
            XCTAssertEqual(map, "map_value")
            XCTAssertEqual(flatMap, "flatMap_value_with_nested_value")
            XCTAssertEqual(flatMapOptional, "nested_value")
            XCTAssertEqual(flatMapError, "flat_map_error")
            XCTAssertEqual(catchUp, "catch_return")
            XCTAssertEqual(replaceNil, "replace_nil")
            XCTAssertEqual(replaceEmpty, ["replace_empty"])
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "key")(String.self)
                .flatMap { _ in nil }
                .to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "key")
                .filter { $0 == "error" }
                .to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <|? "null")
                .filterNil()
                .to(String.self)
        
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "array")
                .filterEmpty()
                .to([String].self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type, value) {
            XCTAssertNotNil(type as? [String].Type)
            XCTAssert((value as? [String])?.isEmpty ?? false)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "missing_key")
                .mapError { _ in TestError() }
                .to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else { XCTFail("\(e)") }
        }
    }
    
    func testSubscriptTransform() {
        let j = JSON(object)
        
        let map = j["key"].distil()
            .map { "map_" + $0 }
            .catch("")
            .to(String.self)
        
        XCTAssertEqual(map, "map_value")
        
        do {
            _ = try j["null"].option()
                .filterNil()
                .to(String.self)
            
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
        
        let just = Distillate<String>.just("just")
        XCTAssertEqual(just.to(String.self), "just")
        
        do {
            _ = try Distillate<String>.filter.to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try Distillate<String>.filter.to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try Distillate<String>.error(TestError()).to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else { XCTFail("\(e)") }
        }
        
        do {
            _ = try (j <| "key")(String.self)
                .flatMap { _ in .filter }
                .to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let DistillError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "missing_key")(String.self)
                .flatMapError { _ in .error(TestError()) }
                .to(String.self)
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is TestError = e {} else {
                XCTFail("\(e)")
            }
        }
    }
    
    func testValueCallbacks() {
        let j = JSON(object)
        
        j.distil("key", to: String.self)
            .value {
                XCTAssertEqual($0, "value")
            }
            .error {
                XCTFail("\($0)")
        }
        
        j.option("null", to: (String?).self)
            .value { XCTAssertEqual($0, nil) }
            .error { XCTFail("\($0)") }
        
        j.distil("key", to: String.self)
            .map { s -> String in "map_" + s }
            .value { XCTAssertEqual($0, "map_value") }
            .map { s -> String in "twice_" + s }
            .value { XCTAssertEqual($0, "twice_map_value") }
            .error { XCTFail("\($0)") }
            .filter { _ in false }
            .value { _ in XCTFail("Expect the error to occur") }
            .error {
                if case let DistillError.filteredValue(type, value) = $0 {
                    XCTAssertNotNil(type as? String.Type)
                    XCTAssertNotNil(value as? String)
                    return
                }
                XCTFail("\($0)")
        }
    }
}
