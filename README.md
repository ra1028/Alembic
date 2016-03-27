# Alembic
[![Swift2.2](https://img.shields.io/badge/swift2.2-compatible-blue.svg?style=flat)](https://developer.apple.com/swift)  
#### Functional JSON decoding, encoding and object mapping library.  

## Overview  
```
do {
    let j = try JSON(data: jsonData)
    
    let string: String = try j <| "string_key"
    let twice: Int = (j <| "int_key")
        .map { $0 * 2 }
        .filter { $0 > 0 }
        .catchUp(0)
    let user: User = try j <| "user"

    let userJSONData = JSON.serializeToData(user)
} catch {
    // Do error handling...
}

class User: Distillable, Serializable {
    let id: Int
    let name: String
    let url: NSURL
    
    required init(json j: JSON) throws {
        try (
            id = j <| "id",
            name = j <| "name",
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
            "name": name,
            "url": url.absoluteString
        ]
    }
}
```

## About  
Alembic is inspired by object mapping library [Argo](https://github.com/thoughtbot/Argo).  
So, greatly thanks for author.

## License  
Alembic is released under the MIT License.