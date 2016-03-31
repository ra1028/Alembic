# Alembic
[![Swift2.2](https://img.shields.io/badge/swift2.2-compatible-blue.svg?style=flat)](https://developer.apple.com/swift)  
#### Functional JSON parsing, mapping to object, and serialize to JSON.

---

## Contents
- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  + [Initialization](#initialization)
  + [JSON parsing](#json-parsing)
  + [Nested objects parsing](#nested-objects-parsing)
  + [Optional objects parsing](#optional-objects-parsing)
  + [Custom Distillable value and object mapping](custom-`distillable`-value-and-object-mapping)
  + [Want you remove the try ?](#want-you-remove-the-`try`-?)
  + [Value transformation](#value-transformation)
  + [Error handling](#error-handling)
  + [Serialize objects to JSON](#serialize-objects-to-json)
- [Playground](#playground)
- [Contribution](#contribution)
- [About](#about)
- [License](#license)

---

## Overview  
```
do {
    let j = try JSON(data: jsonData)

    // Parse by subscript
    let string = try j["string_key"].to(String)

    // Parse by function, and value transform
    let twice: Int = j.distil("int_key")
        .map { $0 * 2 }
        .filter { $0 > 0 }
        .catchUp(0)

    // Mapping to object by custom operator
    let user: User = try j <| "user"

    // Serialize object to NSData of JSON
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
            "name": JSONValue(name),
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
- Powerful parsed value transformation
- Error handling
- class, struct, enum support with non-optional `let` properties
- Functional, Protocol-oriented designs

---

## Requirements
- Swift 2.2 / Xcode 7.3
- iOS 8.0 or later

---

## Installation

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

## Usage

### Initialization
```
import Alembic
```
JSON from AnyObject
```
let j = JSON(jsonObject)
```
JSON from NSData
```
let j = try JSON(data: jsonData)
```
```
let j = try JSON(data: jsonData, options: .AllowFragments)
```
JSON from String  
```
let j = try JSON(string: jsonString)
```
```
let j = try JSON(
    string: jsonString,
    encoding: NSUTF8StringEncoding,
    allowLossyConversion: false,
    options: .AllowFragments
)
```

### JSON parsing
To enable parsing, a class, struct, or enum just needs to implement the `Distillable` protocol.  
```
public protocol Distillable {
    static func distil(j: JSON) throws -> Self
}
```

__Default supported types__  
- `JSON`  
- `String`  
- `Int`  
- `Double`   
- `Float`  
- `Bool`  
- `NSNumber`  
- `Int8`  
- `UInt8`  
- `Int16`  
- `UInt16`  
- `Int32`  
- `UInt32`  
- `Int64`  
- `UInt64`  
- `RawRepresentable`  
- `Array<T: Distillable>`  
- `Dictionary<String, T: Distillable>`  

__Example__
```
let jsonObject = [
    "string_key": "string",  
    "array_key": [1, 2, 3, 4, 5],
]
let j = JSON(jsonObject)
```
function
```
let string: String = try j.distil("string_key")  // "string"
let array = try j.distil("array_key").to([Int])  // [1, 2, 3, 4, 5]
```
custom operator  
```
let string: String = try j <| "string_key"  // "string"
let array = try (j <| "array_key").to([Int])  // [1, 2, 3, 4, 5]
```
subscript
```
let string: String = try j["string_key"].distil()  // "string"
let array = try j["array_key"].to([Int])  // [1, 2, 3, 4, 5]
```

### Nested objects parsing
Supports parsing nested objects with keys and indexes.  
Keys and indexes can be summarized in the same array.  

__Example__
```
let jsonObject = [
    "nested": [        
        "array": [1, 2, 3, 4, 5]
    ]
]
let j = JSON(jsonObject)
```
function
```
let int: Int = try j.distil("nested", "array", 2])  // 3        
```
custom operator
```
let int: Int = try j <| ["nested", "array", 2]  // 3  
```
subscript
```
let int: Int = try j["nested", "array", 2].distil()  // 3  
```

### Optional objects parsing
Has functions to parsing optional objects.  
If the key is missing, returns nil.  

__Example__
```
let jsonObject = [
    "nested": [:] // Nested key is nothing...
]
let j = JSON(jsonObject)
```
function
```
let int: Int? = try j.optional(["nested", "key"])  // nil
```
custom Operator
```
let int: Int? = try j <|? ["nested", "key"]  // nil
```
subscript
```
let int: Int? = try j["nested", "key"].optional()  // nil
```

### Custom `Distillable` value and object mapping
If implement `Distillable` protocol to existing classes like `NSURL`, it be able to parse from JSON.  
Your class, struct, or enum model is also the same.  
To mapping your models, confirm to the `Distillable` protocol.  
Then, parse the value from JSON to all your model properties in the `distill(j: JSON)` function.

```
extension NSURL: Distillable {
    public static func distil(j: JSON) throws -> Self {
        guard let url = try self.init(string: j.distil()) else {
            throw DistilError.TypeMismatch(expected: self, actual: j.raw)
        }
        return url
    }
}
```
```
struct Sample: Distillable {
    let string: String
    let int: Int?

    static func distil(j: JSON) throws -> Sample {
        return try Sample(
            string: j <| "string_key",
            int: j <|? "int_key"
        )
    }
}
```

### Want you remove the `try` ?
Alembic has `catchUp(value)` function.  
Refer the next [Value transfromation Section](#value transformation) for details.  
Use it to remove `try/catch` as following.  

__Example__
```
let jsonObject = ["key": "value"]
let j = JSON(jsonObject)
```
```
let int: String = (j <| "key").catchUp("sub-value")
```

### Value transformation
Alembic supports functional value transformation during the parsing process like `String` -> `NSDate`.  

<table>

<thead>
<tr>
<th>func</th>
<th>description</th>
<th>returns</th>
<th>throws</th>
</tr>
</thead>

<tbody>

<tr>
<td>map(Value throws -> U)</td>
<td>Transform the current value.</td>
<td>U</td>
<td>throw</td>
</tr>

<tr>
<td>filter(Value -> Bool)</td>
<td>If the value is filtered by predicates,  
occur DistillError.FilteredValue.</td>
<td>Value</td>
<td>throw</td>
</tr>

<tr>
<td>catchUp(replace: Value)</td>
<td>If the error is occur, replace it.  
Error handling is not required.</td>
<td>replace</td>
<td></td>
</tr>

<tr>
<td>remapNil(replace: Value.Wrapped)</td>
<td>If the value is nil, replace it.</td>
<td>replace</td>
<td>throw</td>
</tr>

<tr>
<td>ensure(replace: Value.Wrapped)</td>
<td>If the value is nil or the error is occur, replace it.  
Error handling is not required.</td>
<td>replace</td>
<td></td>
</tr>

<tr>
<td>filterNil()</td>
<td>If the value is nil,  
occur DistillError.FilteredValue.</td>
<td>Value.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>remapEmpty(replace: Value)</td>
<td>If the value is empty of CollectionType,  
replace it.</td>
<td>replace</td>
<td>throw</td>
</tr>

<tr>
<td>filterEmpty()</td>
<td>If the value is empty of CollectionType,  
occur DistillError.FilteredValue.</td>
<td>Value</td>
<td>throw</td>
</tr>

</tbody>
</table>

__Example__
```
let jsonObject = [
    "time_string": "2016-04-01 00:00:00"
]
let j = JSON(jsonObject)
```
function
```
let date: NSDate = j.distil("time_string")(String)  // "Apr 1, 2016, 12:00 AM"
    .map { s -> NSDate? in
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.dateFromString(s)
    }
    .ensure(NSDate())
```
custom operator
```
let date: NSDate = (j <| "time_string")(String)  // "Apr 1, 2016, 12:00 AM"
    .map { s -> NSDate? in
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.dateFromString(s)
    }
    .ensure(NSDate())
```
subscript
```
let date: NSDate = j["time_string"].distil(String)  // "Apr 1, 2016, 12:00 AM"
    .map { s -> NSDate? in
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.dateFromString(s)
    }
    .ensure(NSDate())
```

### Error handling
Alembic has simple error handling designs as following.  
If you don't care about error handling, use `try?` or `(j <| "key").catchUp(value)`.  

__DistilError__
- case MissingPath(JSONPath)  
- case TypeMismatch(expected: Any.Type, actual: AnyObject)  
- case FilteredValue(Any)  

<table>
<thead>
<tr>
<th>func</th>
<th>null</th>
<th>missing key</th>
<th>type mismatch</th>
<th>error in sub-objects</th>
</tr>
</thead>

<tbody>

<tr>
<td>
try j.distil(path)  
try j <| path
try j[path].to(type)
</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try j.optional(path)  
try j <|? path
</td>
<td>nil</td>
<td>nil</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try? j.distil(path)  
try? j <| path
try? j[path].to(type)
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

<tr>
<td>
try? j.optional(path)  
try? j <|? path
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

</tbody>
</table>

### Serialize objects to JSON
To Serialize objects to `NSData` or `String` of JSON, your models should implements the `Serializable` protocol.  
```
public protocol Serializable {
    func serialize() -> JSONObject
}
```
`serialize()` function returns the `JSONObject`.  

- JSONObject  
  `init` with `Array<T: JSONValueConvertible>` or `Dictionary<String, T: JSONValueConvertible>` only.  
  Implemented the `ArrayLiteralConvertible` and `DictionaryLiteralConvertible`.
- JSONValueConvertible  
  The protocol that to be convert to `JSONValue` with ease.
- JSONValue  
  For constraint to the types that allowed as value of JSON.   

__Defaults JSONValueConvertible implemented types__  
- `String`  
- `Int`  
- `Double`  
- `Float`  
- `Bool`  
- `NSNumber`  
- `Int8`  
- `UInt8`  
- `Int16`  
- `UInt16`  
- `Int32`  
- `UInt32`  
- `Int64`  
- `UInt64`  
- `RawRepresentable`  
- `JSONValue`  

__Example__
```
let user: User = ...
let data = JSON.serializeToData(user)
let string = JSON.serializeToString(user)

enum Gender: String, JSONValueConvertible {
    case Male = "male"
    case Female = "female"

    private var jsonValue: JSONValue {
        return JSONValue(rawValue)
    }
}

struct User: Serializable {
    let id: Int
    let name: String    
    let gender: Gender
    let friendIds: [Int]

    func serialize() -> JSONObject {
        return [
            "id": id,
            "name": name,            
            "gender": gender,
            "friend_ids": JSONValue(friendIds)
        ]
    }
}
```

### More Example
See the Alembic `Tests` for more examples.  
If you want to try Alembic, use Alembic [Playground](#playground).

---

## Playground
- Open `Alembic.xcworkspace`
- Build Alembic
- Then, open `Alembic` playground in `Alembic.xcworkspace` tree view.
- Enjoy Alembic!

---

## Contribution
Welcome to fork and submit pull requests!!  

Before submitting pull request, please ensure you have passed the included tests.  
If your pull request including new function, please write test cases for it.  

(Also, welcome the offer of Alembic logo image :pray:)

---

## About  
Alembic is inspired by great libs [Argo](https://github.com/thoughtbot/Argo), [Himotoki](https://github.com/ikesyo/Himotoki), [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON),
.  
Greatly thanks for authors!! :beers:.  

---

## License  
Alembic is released under the MIT License.

---
