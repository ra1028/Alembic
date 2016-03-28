# Alembic
[![Swift2.2](https://img.shields.io/badge/swift2.2-compatible-blue.svg?style=flat)](https://developer.apple.com/swift)  
#### Functional JSON parsing, object mapping, and serialize to JSON.

---

## Overview  
```
do {
    let j = try JSON(data: jsonData)

    let string = try (j <| "string_key").to(String)
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
- Powerful parsed value transformation
- Error handling
- class, struct, enum support with non-optional ``let`` properties
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
``import Alembic``  
```
let j = JSON(jsonObject)
```
```
let j = try JSON(data: jsonData)
//or
let j = try JSON(data: jsonData, options: .AllowFragments)
```  
```
let j = try JSON(string: jsonString)
// or
let j = JSON(
    string: jsonString,
    encoding: NSUTF8StringEncoding,
    allowLossyConversion: false,
    options: .AllowFragments
)
```

### JSON parsing
To enable parsing, a class, struct, or enum just needs to implement the ``Distillable`` protocol.  
```
public protocol Distillable {
    static func distil(j: JSON) throws -> Self
}
```

__Default supported types__  
- String  
- Int  
- Double  
- Float  
- Bool  
- NSNumber  
- Int8  
- UInt8  
- Int16  
- UInt16  
- Int32  
- UInt32  
- Int64  
- UInt64  
- RawRepresentable  
- JSON  
- Array\<T: Distillable\>  
- Dictionaly\<String, T: Distillable\>  

__Example__
```
let jsonObject = [
    "string_key": "string",  
    "array_key": [1, 2, 3, 4, 5],
]
do {
    let j = JSON(jsonObject)

    let string: String = try j <| "string_key"  // "string"
    let array: [Int] = try j <| "array_key"  // [1, 2, 3, 4, 5]

    // also
    // let string = try (j <| "string_key").to(String)
    // let string: String = try j.distil("string_key")
} catch {
    // Do error handling...
}
```

### Nested objects parsing
Alembic supports JSON keys and JSON array indexes.  
Keys and indexes can be summarized in the same array.  

__Example__
```
let jsonObject = [
    "nested": [
        "int_key": 100,
        "array_key": [1, 2, 3, 4, 5]
    ]
]
do {
    let j = JSON(jsonObject)
    let int: Int = try j <| ["nested", "int_key"]  // 100
    let intFromArray: Int = try j <| ["nested", "array_key", 2]  // 3
} catch {
    // Do error handling...
}
```

### Custom ``Distillable`` value and Object mapping
If implement ``Distillable`` protocol to existing classes like ``NSURL``, it be able to parse from JSON.  
Your class, struct, or enum model is also the same.  
To mapping your models, confirm to the ``Distillable`` protocol.  
Then, parse the value from JSON to all your model properties in the ``distill(j: JSON)`` function.

```
extension NSURL: Distillable {
    public static func distil(j: JSON) throws -> Self {
        guard let url = try self.init(string: j.distil()) else {
            throw DistilError.TypeMismatch(expected: NSURL.self, actual: j.raw)
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

### Want you remove the ``try`` ?
Alembic has ``catchUp(value)`` function.  
Refer the next section(Value transfromation) for details.  
Use it to remove ``try/catch`` as following.  

__Example__
```
let jsonObject = ["key": "value"]
let j = JSON(jsonObject)

let int: String = (j <| "key").catchUp("substitute")
```

### Value transformation
Alembic supports functional value transformation during the parsing process like ``String`` -> NSDate.  

__functions__
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
No longer to required the error handling.</td>
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
No longer to required the error handling.</td>
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
    "time_stamp": [
        "2016-04-01 00:00:00",
        "2016-04-02 01:00:00",
        "2016-04-03 02:00:00",
        "2016-04-04 03:00:00",
        "2016-04-05 04:00:00",
    ]
]
let j = JSON(jsonObject)
let timeStamp = (j <|? "time_stamp")([String]?)
    .filterNil()
    .map {
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return $0.flatMap(formatter.dateFromString)
    }
    .catchUp([])
    .to([NSDate])
```
### Error handling
Alembic has simple error handling designs as following.
If you don't care about error handling, use ``try?`` or ``(j <| "key").catchUp(value)``.

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
<td>try j.distil(path)  
try j <| path</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>try j.optional(path)  
try j <|? path</td>
<td>nil</td>
<td>nil</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>try? j.distil(path)  
try? j <| path</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

<tr>
<td>try? j.optional(path)  
try? j <|? path</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

</tbody>
</table>

### Serialize objects to JSON
To Serialize objects to ``NSData`` or ``String`` of JSON, your models should implements the ``Serializable`` protocol.  
```
public protocol Serializable {
    func serialize() -> JSONObject
}
```
``serialize()`` function returns the ``JSONObject``.  

- JSONObject  
  ``init`` with ``Array<T: JSONValueConvertible>`` or ``Dictionary<String, T: JSONValueConvertible>`` only.  
  Implemented the ``ArrayLiteralConvertible`` and ``DictionaryLiteralConvertible``.
- JSONValueConvertible  
  The protocol that to be convert to ``JSONValue`` with ease.
- JSONValue  
  For constraint to the types that allowed as value of JSON.   

__Defaults JSONValueConvertible implemented types__  
- String  
- Int  
- Double  
- Float  
- Bool  
- NSNumber  
- Int8  
- UInt8  
- Int16  
- UInt16  
- Int32  
- UInt32  
- Int64  
- UInt64  
- RawRepresentable  
- JSONValue  

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

## About  
Alembic is inspired by object mapping library [Argo](https://github.com/thoughtbot/Argo).  
Greatly thanks for author!!.

---

## License  
Alembic is released under the MIT License.

---
