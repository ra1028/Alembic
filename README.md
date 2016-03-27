# Alembic
[![Swift2.2](https://img.shields.io/badge/swift2.2-compatible-blue.svg?style=flat)](https://developer.apple.com/swift)  
#### Functional JSON parsing, object mapping, and serialize to JSON.

---

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
```

---

## Features
- JSON parsing with ease
- Mapping JSON to objects
- Type-safe serialize object to JSON
- Powerful parsed value transform
- Error handling
- class, struct, enum support with non-optional ``let`` properties
- Functional, Protocol-oriented designs

---

## Requirements
- Swift 2.2 / Xcode 7.3
- iOS 8.0 or later

---

## Installation

### [Swift Package Manager](https://swift.org/package-manager/)
// TODO:
Add the following to your [Package.swift](https://github.com/apple/swift-package-manager/blob/master/Documentation/Package.swift.md):
```
.Package(url: "https://github.com/ra1028/Alembic.git", majorVersion: 0)
```

### [CocoaPods](https://cocoapods.org/)
// TODO:  
Add the following to your Podfile:
```
use_frameworks!
pod 'Alembic'
```

### [Carthage](https://github.com/Carthage/Carthage)
// TODO:  
Add the following to your Cartfile:
```
github "ra1028/Alembic"
```

### [CocoaSeeds](https://github.com/devxoul/CocoaSeeds)
Add the following to your Seedfile:
```
github "ra1028/Alembic", :files => "Sources/**/*.swift"
```

---

## About  
Alembic is inspired by object mapping library [Argo](https://github.com/thoughtbot/Argo).  
Greatly thanks for author!!.

---

## License  
Alembic is released under the MIT License.

---
