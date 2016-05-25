//
//  TransformTests.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
import Alembic

class TransformTests: XCTestCase {
    let object = TestJSON.Transform.object
    
    func testTransform() {
        let j = JSON(object)
        
        do {
            let map: String = try (j <| "key")
                .map { "map_" + $0 }
            let flatMap: String = try (j <| ["nested", "nested_key"])(String)
                .flatMap { v -> Distillate<String> in return (j <| "key").map { "flatMap_" + $0 + "_with_" + v } }
            let catchUp: String = (j <| "error")
                .catchReturn("catch_up")
            let replaceNil: String = try (j <|? "null")
                .replaceNil("remap_nil")
            let replaceEmpty: [String] = try (j <| "array")
                .replaceEmpty(["remap_empty"])
            
            XCTAssertEqual(map, "map_value")
            XCTAssertEqual(flatMap, "flatMap_value_with_nested_value")
            XCTAssertEqual(catchUp, "catch_up")
            XCTAssertEqual(replaceNil, "remap_nil")
            XCTAssertEqual(replaceEmpty, ["remap_empty"])
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "key")
                .filter { $0 == "error" }
                .to(String)
            
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <|? "null")
                .filterNil()
                .to(String)
        
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "array")
                .filterEmpty()
                .to([String])
            
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(type, value) {
            XCTAssertNotNil(type as? [String].Type)
            XCTAssert((value as? [String])?.isEmpty ?? false)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testSubscriptTransform() {
        let j = JSON(object)
        
        let map = j["key"].distil()
            .map { "map_" + $0 }
            .catchReturn("")
            .to(String)
        
        XCTAssertEqual(map, "map_value")
        
        do {
            _ = try j["null"].option()
                .filterNil()
                .to(String)
            
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
    }
}