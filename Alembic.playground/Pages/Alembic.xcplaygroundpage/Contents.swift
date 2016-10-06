/*:
 ## Welcome to `Alembic` Playground!!
 ----
 > 1. Open Alembic.xcworkspace.
 > 2. Build the Alembic for Mac.
 > 3. Open Alembic playground in project navigator.
 > 4. Enjoy the Alembic!
*/
import Alembic

struct Nested: Distillable {
    let id: Int
    
    static func distil(json j: JSON) throws -> Nested {
        return Nested(id: try j <| "invalid_key")
    }
}

final class Sample: InitDistillable {
    let id: Int
    let nested: Nested
    
    init(json j: JSON) throws {
        id = try j <| "id"
        nested = try j <| "nested"
    }
}

let object: [String: Any] = [
    "key": "WOO",
    "nested": ["key": 100],
    "sample": ["id": 100, "nested": ["id": 5]],
    "value": 5000
]

do {
    
    let j = JSON(object)
    
    let str: String = try j["key"].distil()
    let missing: String? = try j["missing"].option()
    let nested: Int = try j["nested"]["key"].distil()
    let nestedOpt: Int? = try j["nested"]["key"].option()
    let value = try j["value"].distil(to: Int.self).map { $0 * 2 }.value {
        print($0); return
    }
    
//    let sample: Sample = try j["sample"].distil()
//    let errorCase1: Int = try j["nested"]["missing"].distil()

} catch let error {
    
    print(error)
    
}

let jsonString = "{\"key\" 100}"
let j2 = JSON(string: jsonString)

do {
    
    let v: Int = try j2.distil("key")
    
} catch let error {
    
    print(error)
    
}

let jsonData = jsonString.data(using: .utf8, allowLossyConversion: false)!
let j3 = JSON(data: jsonData)

do {
    
    let v: Int = try j3.distil("key")
    
} catch let error {
    
    print(error)
    
}