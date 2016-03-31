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
    func testTransform() {
        let object = TestJSON.Transform.object
        let j = JSON(object)
        
        do {
            let map: String = try (j <| "key")
                .map { "map_" + $0 }
            let catchUp: String = (j <| "error")
                .catchUp("catch_up")
            let remapNil: String = try (j <|? "null")
                .remapNil("remap_nil")
            let ensureError: String = (j <|? "error")
                .ensure("ensure_error")
            let ensureNil: String = (j <|? "null")
                .ensure("ensure_nil")
            let remapEmpty: [String] = try (j <| "array")
                .remapEmpty(["remap_empty"])
            
            XCTAssertEqual(map, "map_value")
            XCTAssertEqual(catchUp, "catch_up")
            XCTAssertEqual(remapNil, "remap_nil")
            XCTAssertEqual(ensureError, "ensure_error")
            XCTAssertEqual(ensureNil, "ensure_nil")
            XCTAssertEqual(remapEmpty, ["remap_empty"])
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "key")
                .filter { $0 == "error" }
                .to(String)
            
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(value) {
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <|? "null")
                .filterNil()
                .to(String)
        
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(value) {
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try (j <| "array")
                .filterEmpty()
                .to([String])
            
            XCTFail("Expect the error to occur")
        } catch let DistilError.FilteredValue(value) {
            XCTAssert((value as? [String])?.isEmpty ?? false)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testSubscriptTransform() {
        let object = TestJSON.Transform.object
        let j = JSON(object)
        
        let map = j["key"].distil()
            .map { "map_" + $0 }
            .catchUp("")
            .to(String)
        
        XCTAssertEqual(map, "map_value")

    }
}