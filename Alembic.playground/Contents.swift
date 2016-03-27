import UIKit
import Alembic

let jsonObject = [
    "string_key": "string",
    "int_key": 100,
    "user": [
        "id": 200,
        "name": "ra1028",
        "contact": [
            "url": "http://example.com"
        ]
    ]
]

class User: Distillable, Serializable {
    let id: Int
    let name: String?
    let url: NSURL
    
    required init(json j: JSON) throws {
        try (
            id = j <| "id",
            name = j <|? "name",
            url = (j <| ["contact", "url"])
                .map(NSURL.init(string:))
                .filterNil()
        )
    }
    
    static func distil(j: JSON) throws -> Self {
        return try self.init(json: j)
    }
    
    func serialize() -> JSONObject {
        return [
            "id": id,
            "name": name.map { JSONValue($0) } ?? .null,
            "url": url.absoluteString
        ]
    }
}

do {
    let j = JSON(jsonObject)
    
    let string: String = try j <| "string_key"
    let twice: Int = (j <| "int_key")
        .map { $0 * 2 }
        .filter { $0 > 0 }
        .catchUp(0)
    let user: User = try j <| "user"
    
    let userJSONData = JSON.serializeToData(user)
} catch let e {
    // Do error handling...
}
