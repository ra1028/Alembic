//
//  DistilTests.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
import Alembic

class DistilTests: XCTestCase {
    func testDistil() {
        guard let object = JSONProvider.object("DistilTests") else {
            XCTFail()
            return
        }
        
        let j = JSON(object)
        
        do {
            let string: String = try j <| "string"
            let int: Int = try j <| "int"
            let double: Double = try j <| "double"
            let float: Float = try j <| "float"
            let bool: Bool = try j <| "bool"
            let array: [String] = try j <| "array"
            let dictionary: [String: Int] = try j <| "dictionary"
            let nestedValue: Int = try j <| ["nested", "array", 2]
            let nestedArray: [Int] = try j <| ["nested", "array"]
            
            XCTAssert(string == "Alembic")
            XCTAssert(int == 777)
            XCTAssert(double == 77.7)
            XCTAssert(float == 77.7)
            XCTAssert(bool == true)
            XCTAssert(array == ["A", "B", "C"])
            XCTAssert(dictionary == ["A": 1, "B": 2, "C": 3])
            XCTAssert(nestedValue == 3)
            XCTAssert(nestedArray == [1, 2, 3, 4, 5])
        } catch let e {
            XCTFail("\(e)")
        }
        
    }
    
    func testClassMapping() {
        guard let data = JSONProvider.data("DistilTests"),
            j = try? JSON(data: data) else {
                XCTFail()
                return
        }
        
        do {
            let user: User = try j <| "user"
            
            XCTAssert(user.id == 100)
            XCTAssert(user.name == "ra1028")
            XCTAssert(user.weight == 132.28)
            XCTAssert(user.gender == .Male)
            XCTAssert(user.smoker == true)
            XCTAssert(user.email == "r.fe51028.r@gmail.com")
            XCTAssert(user.url.absoluteString == "https://github.com/ra1028")
            XCTAssert(user.friends.count == 1)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testStructMapping() {
        guard let object = JSONProvider.object("DistilTests") else {
            XCTFail()
            return
        }
        
        let j = JSON(object)
        
        do {
            let numbers: Numbers = try j <| "numbers"
            
            XCTAssert(numbers.number == 1)
            XCTAssert(numbers.int8 == 2)
            XCTAssert(numbers.uint8 == 3)
            XCTAssert(numbers.int16 == 4)
            XCTAssert(numbers.uint16 == 5)
            XCTAssert(numbers.int32 == 6)
            XCTAssert(numbers.uint32 == 7)
            XCTAssert(numbers.int64 == 8)
            XCTAssert(numbers.uint64 == 9)
        } catch let e {
            XCTFail("\(e)")
        }
    }
}

extension NSURL: Distillable {
    public static func distil(j: JSON) throws -> Self {
        guard let url = try self.init(string: j.distil()) else {
            throw DistilError.TypeMismatch(expected: NSURL.self, actual: j.raw)
        }
        return url
    }
}

private enum Gender: String, Distillable {
    case Male = "male"
    case Female = "female"
}

private class User: Distillable {
    let id: Int
    let name: String    
    let weight: Double
    let gender: Gender
    let smoker: Bool
    let email: String
    let url: NSURL
    let friends: [User]
    
    required init(json j: JSON) throws {
        try (
            id = j <| "id",
            name = j <| "name",
            weight = j <| "weight",
            gender = j <| "gender",
            smoker = j <| "smoker",
            email = j <| ["contact", "email"],
            url = j <| ["contact", "url"],
            friends = j <| "friends"
        )
    }
    
    private static func distil(j: JSON) throws -> Self {
        return try self.init(json: j)
    }
}

private struct Numbers: Distillable {
    let number: NSNumber
    let int8: Int8
    let uint8: UInt8
    let int16: Int16
    let uint16: UInt16
    let int32: Int32
    let uint32: UInt32
    let int64: Int64
    let uint64: UInt64
    
    private static func distil(j: JSON) throws -> Numbers {
        return try Numbers(
            number: j <| "number",
            int8: j <| "int8",
            uint8: j <| "uint8",
            int16: j <| "int16",
            uint16: j <| "uint16",
            int32: j <| "int32",
            uint32: j <| "uint32",
            int64: j <| "int64",
            uint64: j <| "uint64"
        )
    }
}