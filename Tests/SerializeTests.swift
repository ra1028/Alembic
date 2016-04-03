//
//  SerializeTests.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/28/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
import Alembic

class SerializeTests: XCTestCase {
    let object = TestJSON.Serialize.object
    
    private lazy var user: User = {
        let object = TestJSON.Serialize.object
        return try! JSON(object) <| "user"
    }()
    
    private lazy var users: [User] = {
        return (0..<10).map { _ in try? JSON(self.object) <| "user" }
            .flatMap { $0 }
    }()
    
    func testSerializeToData() {
        let data = JSON.serializeToData(user)
        
        guard case let object?? = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(object["id"] as? Int, 100)
        XCTAssertEqual(object["name"] as? String, "ra1028")
        XCTAssertEqual(object["weight"] as? Float, 132.28)
        XCTAssertEqual(object["gender"] as? String, "male")
    }
    
    func testSerializeToString() {
        let string = JSON.serializeToString(user)
        
        guard let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
            case let object?? = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject]
            else {
                XCTFail()
                return
        }
        
        XCTAssertEqual(object["id"] as? Int, 100)
        XCTAssertEqual(object["name"] as? String, "ra1028")
        XCTAssertEqual(object["weight"] as? Float, 132.28)
        XCTAssertEqual(object["gender"] as? String, "male")
    }
    
    func testArraySerializeToData() {
        let data = JSON.serializeToData(users)
        
        guard case let object?? = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [[String: AnyObject]] else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(object.count, 10)
    }
    
    func testArraySerializeToString() {
        let string = JSON.serializeToString(users)
        
        guard let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false),
            case let object?? = try? NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [[String: AnyObject]]
            else {
                XCTFail()
                return
        }
        
        XCTAssertEqual(object.count, 10)
    }
}

private enum Gender: String, Distillable, JSONValueConvertible {
    case Male = "male"
    case Female = "female"
    
    private var jsonValue: JSONValue {
        return JSONValue(rawValue)
    }
}

private struct User: Distillable, Serializable {
    let id: Int
    let name: String
    let weight: Double
    let gender: Gender
    
    private static func distil(j: JSON) throws -> User {
        return try User(
            id: j <| "id",
            name: j <| "name",
            weight: j <| "weight",
            gender: j <| "gender"
        )
    }
    
    private func serialize() -> JSONObject {
        return [
            "id": id,
            "name": name,
            "weight": weight,
            "gender": gender
        ]
    }
}