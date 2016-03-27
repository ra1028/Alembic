# Alembic
[![Swift2.2](https://img.shields.io/badge/swift2.2-compatible-blue.svg?style=flat)](https://developer.apple.com/swift)  
#### Functional JSON parsing and object mapping library.  

## Overview  
```
enum Gender: String, Distillable {
    case Male = "male"
    case Female = "female"
}

class User: Distillable {
    let id: Int
    let name: String
    let gender: Gender
    let url: NSURL
    
    required init(json j: JSON) throws {
        try (
            id = j <| "id",
            name = j <| "name",
            gender = j <| "gender",
            url = (j <| ["contact", "url"])
                .map(NSURL.init(string:))
                .filterNil()
        )
    }

    private static func distil(j: JSON) throws -> Self {
        return try self.init(json: j)
    }
}

do {
    let j = try JSON(data: jsonData)
    let user: User = j <| "user"
    // ...
} catch let e {
    // Do error handling...
}
```