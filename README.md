<p align="center">
<img src="https://raw.githubusercontent.com/ra1028/Alembic/master/Assets/Alembic_Logo.png" alt="Alembic" width="70%"></p>
</br>

<p align="center">

<a href="https://developer.apple.com/swift"><img alt="Swift3" src="https://img.shields.io/badge/language-swift3-orange.svg?style=flat"/></a>
<a href="https://travis-ci.org/ra1028/Alembic"><img alt="Build Status" src="https://travis-ci.org/ra1028/Alembic.svg?branch=master"/></a>
<a href="https://codebeat.co/projects/github-com-ra1028-alembic"><img alt="CodeBeat" src="https://codebeat.co/badges/09cc20c0-4cba-4c78-8e20-39f41d86c587"/></a></br>

<a href="https://cocoapods.org/pods/Alembic"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Alembic.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg?style=flat"/></a>
<a href="https://github.com/apple/swift-package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/SwiftPM-compatible-blue.svg"/></a></br>

<a href="https://developer.apple.com/swift/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS%20%7C%20OSX%20%7C%20tvOS%20%7C%20watchOS%20%7C%20Linux-green.svg"/></a>
<a href="https://github.com/ra1028/Alembic/blob/master/LICENSE"><img alt="Lincense" src="http://img.shields.io/badge/license-MIT-000000.svg?style=flat"/></a></br>

</p>

<p align="center">
<H4 align="center">Functional JSON parsing</H4>
</p>  

---

### :penguin: _Alembic_ is now __Linux Ready!__ :penguin:
### [Learn how to use _Alembic_ on IBM Swift Sandbox](https://swiftlang.ng.bluemix.net/#/repl?gitPackage=https:%2F%2Fgithub%2Ecom%2Fra1028%2FAlembic%2DSample%2Egit)  

---

## Contents
- [Introduction](#introduction)
- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  + [Initialization](#initialization)
  + [JSON parsing](#json-parsing)
  + [Nested objects parsing](#nested-objects-parsing)
  + [Optional objects parsing](#optional-objects-parsing)
  + [Custom value parsing](#custom-value-parsing)
  + [Object mapping](#object-mapping)
  + [Value transformation](#value-transformation)
  + [Error handling](#error-handling)
- [Playground](#playground)
- [Contribution](#contribution)
- [License](#license)

---

## Introduction
_Alembic_ is library for provide functional JSON parsing and object-mapping that designed as monad.  
Monad is provide a benefit that you can express the lazy evaluated transformation such as map or filter.  
Besides, it's very scalable, because parseable value or class types are generic via protocol-oriented.  
Type-safe and fail-safe designs would be also helps your quick development.  

---

## Overview  
```Swift
let j = JSON(obj)
```
Value parsing
```Swift
let value: String = try j.decode("key")
```
```Swift
let value: String = try j <| "key"
```
```Swift
let value: String = try j["key"].decode()
```
Object mapping
```Swift
let user: User = try j.decode("user")

struct User: Decodable {
    let name: String
    let avatarUrl: URL

    static func value(from json: JSON) throws -> User {
        return try User(
            name: j.decode("name"),
            avatarUrl: j.decode("avatar_url").flatMap(URL.init(string:))
        )
    }
}
```
Using like [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON)  
```Swift
let json = JSON(data: data)
if let userName = try? json[0]["user"]["name"].to(String.self) {
    print(userName)
}
```

---

## Requirements
- Swift 3 / Xcode 8
- OS X 10.9 or later
- iOS 8.0 or later
- watchOS 2.0 or later
- tvOS 9.0 or later
- Linux

---

## Installation

### [CocoaPods](https://cocoapods.org/)  
Add the following to your Podfile:
```ruby
use_frameworks!

target 'YOUR_TARGET_NAME' do
  pod 'Alembic'
end
```

### [Carthage](https://github.com/Carthage/Carthage)  
Add the following to your Cartfile:
```ruby
github "ra1028/Alembic"
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)
Add the following to your Package.swift:
```Swift
let package = Package(
    name: "ProjectName",
    dependencies: [
        .Package(url: "https://github.com/ra1028/Alembic.git", majorVersion: 2)
    ]
)
```

---

## Usage

### Initialization
```Swift
import Alembic
```
JSON from Any
```Swift
let j = JSON(any)
```
JSON from Data
```Swift
let j = JSON(data: data)
```
```Swift
let j = JSON(data: data, options: .allowFragments)
```
JSON from String  
```Swift
let j = JSON(string: string)
```
```Swift
let j = JSON(
    string: string,
    encoding: .utf8,
    allowLossyConversion: false,
    options: .allowFragments
)
```

### JSON parsing
To enable parsing, a class, struct, or enum just needs to implement the `Decodable` or `Initializable` protocol.  
```Swift
public protocol Decodable {
    static func value(from json: JSON) throws -> Self
}
```
```Swift
public protocol Initializable: Decodable {
    init(json j: JSON) throws
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
- `Array<T: Decodable>`  
- `Dictionary<String, T: Decodable>`  

__Example__
```Swift
let object = ["key": "string"]
let j = JSON(object)
```
```Swift
let string: String = try j.decode("key")  // "string"
```
```Swift
let string: String = try j <| "key"  // "string"
```
```Swift
let string: String = try j["key"].decode()  // "string"
```

__Tips__  
You can set the generic type as following:  
```Swift
let string = try j.decode("key").to(String.self)  // "string"
```
It's same if use operator or subscript.  

### Nested objects parsing
Supports parsing nested objects with keys and indexes.  
Keys and indexes can be containing in the same array.  

__Example__
```Swift
let object = ["nested": ["array": [1, 2, 3, 4, 5]]]
let j = JSON(object)
```
```Swift
let int: Int = try j.decode(["nested", "array", 2])  // 3        
```
```Swift
let int: Int = try j <| ["nested", "array", 2]  // 3  
```
```Swift
let int: Int = try j["nested", "array", 2].decode()  // 3  
let int: Int = try j["nested"]["array"][2].decode()  // 3  
```

### Optional objects parsing
Also supports to parse optional objects.  
If the key is missing or value is null, returns nil.  

__Example__
```Swift
let object = ["nested": [:]] // Nested key is nothing...
let j = JSON(object)
```
```Swift
let int: Int? = try j.decodeOption(["nested", "key"])  // nil
```
```Swift
let int: Int? = try j <|? ["nested", "key"]  // nil
```
```Swift
let int: Int? = try j["nested", "key"].decodeOption()  // nil
let int: Int? = try j["nested"]["key"].decodeOption()  // nil
```

### Custom value parsing
If implement `Decodable` or `Initializable` protocol to existing classes like `URL`, it can be parse from JSON.  

__Example__
```Swift
let object = ["key": "http://example.com"]
let j = JSON(object)
```
Decodable
```Swift
extension URL: Decodable {
    public static func value(from json: JSON) throws -> URL {
        return try j.decode().flatMap(self.init(string:))
    }
}
```
Initializable
```Swift
extension URL: Initializable {
    public init(json j: JSON) throws {
        self = try j.decode().flatMap(URL.init(string:))
    }
}
```
```Swift
let url: URL = try j <| "key"  // http://example.com
```

### Object mapping  
To mapping your models, need implements the `Decodable` or `Initializable` protocol.  
Then, parse the objects from JSON to all your model properties.  
__`Initializable` protocol can't implement to non `final` class.__  

__Example__
```Swift
let object = [
    "key": [
        "string_key": "string",
        "option_int_key": NSNull()
    ]
]
let j = JSON(object)
```
Decodable
```Swift
struct Sample: Decodable {
    let string: String
    let int: Int?

    static func value(from json: JSON) throws -> Sample {
        return try Sample(
            string: j <| "string_key",
            int: j <|? "option_int_key"
        )
    }
}
```
Initializable
```Swift
struct Sample: Initializable {
    let string: String
    let int: Int?

    init(json j: JSON) throws {
        try string = j <| "string_key"
        try int = j <|? "option_int_key"
    }
}
```
```Swift
let sample: Sample = try j <| "key"  // Sample
```

### Value transformation
Alembic supports functional value transformation during the parsing process like `String` -> `Date`.  
Parsing functions are also can return `Distillate` object.  
So, you can use 'map' 'flatMap' and other following useful functions.  

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
<td>flatMap(Value throws -> (U: DistillateType))</td>
<td>Returns the value containing in U.</td>
<td>U.Value</td>
<td>throw</td>
</tr>

<tr>
<td>flatMap(Value throws -> U?)</td>
<td>Returns the non-nil value.<br>
If the transformed value is nil,<br>
throw DecodeError.filteredValue</td>
<td>U.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>mapError(Error throws -> ErrorType)</td>
<td>If the error thrown, replace its error.</td>
<td>Value</td>
<td>throw</td>
</tr>

<tr>
<td>flatMapError(Error throws -> (U: DistillateType))</td>
<td>If the error thrown, flatMap its error.</td>
<td>U.Value</td>
<td>throw</td>
</tr>

<tr>
<td>filter(Value throws -> Bool)</td>
<td>If the value is filtered by predicates,<br>
throw DecodeError.filteredValue.</td>
<td>Value</td>
<td>throw</td>
</tr>

<tr>
<td>catch(Value)</td>
<td>If the error was thrown, replace it.<br>
Error handling is not required.</td>
<td>Value</td>
<td></td>
</tr>

<tr>
<td>catch(ErrorType -> Value)</td>
<td>If the error was thrown, replace it.<br>
Error handling is not required.</td>
<td>Value</td>
<td></td>
</tr>

<tr>
<td>replaceNil(Value.Wrapped)</td>
<td>If the value is nil, replace it.</td>
<td>Value.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>replaceNil(() throws -> Value.Wrapped)</td>
<td>If the value is nil, replace it.</td>
<td>Value.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>filterNone()</td>
<td>If the value is nil,<br>
throw DecodeError.filteredValue.</td>
<td>Value.Wrapped</td>
<td>throw</td>
</tr>

</tbody>
</table>

__Example__
```Swift
let object = ["time_string": "2016-04-01 00:00:00"]
let j = JSON(object)
```
function
```Swift
let date: Date = j.decode("time_string", as: String.self)  // "Apr 1, 2016, 12:00 AM"
    .filter { !$0.isEmpty }
    .flatMap { dateString in
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return fmt.date(from: dateString)
    }
    .catch(Date())
```

__Tips__  
When the transforming is complicated, often generic type is missing.  
At that time, set the type explicitly as following:  
```Swift
let value: String = try j.decode("number", as: Int.self).map { "Number \($0)" }
```
```Swift
let value: String = try (j <| "number")(Int.self).map { "Number \($0)" }
```
```Swift
let value: String = try j["number"].decode(as: Int.self).map { "Number \($0)" }
```

You can create `Distillate` by `Distillate.filter()`, `Distillate.error(error)` and `Distillate.just(value)`.  
It's provide more convenience to value-transformation.  
Example:  

```Swift
struct FindAppleError: Error {}

let message: String = try j.decode("number_of_apples", as: Int.self)
    .flatMap { count -> Distillate<String> in
        count > 0 ? .just("\(count) apples found!!") : .filter()
    }
    .flatMapError { _ in .error(FindAppleError()) }
    .catch { error in "Anything not found... | Error: \(error)" }
```

Alembic enable you to receive a value with closure.  
```Swift
let jsonObject = ["user": ["name": "Robert Downey, Jr."]]
let j = JSON(jsonObject)
```
```Swift		
j.decode(["user", "name"], to: String.self)
    .map { name in "User name is \(name)" }
    .value { message in
        print(message)  // "Robert Downey, Jr."
    }
    .error { error in
        print(error)  // NOP
    }
```

### Error handling
Alembic has powerfull error handling designs as following.  
It will be help your fail-safe coding.  

__DecodeError__
- missingPath(Path)  
- typeMismatch(expected: Any.Type, actual: Any, path: Path)  
- filteredValue(type: Any.Type, value: Any)  
- serializeFailed(with: Any)  

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
try j.decode(path)<br>
try j <| path<br>
try j[path].decode()<br>
</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try j.decodeOption(path)<br>
try j <|? path<br>
try j[path].decodeOption()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try? j.decode(path)<br>
try? j <| path<br>
try? j[path].decode()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

<tr>
<td>
try? j.decodeOption(path)<br>
try? j <|? path<br>
try? j[path].decodeOption()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

</tbody>
</table>

__Don't wanna handling the error?__  
If you don't care about error handling, use `try?` or `j.decode("key").catch(value)`.  
```Swift
let value: String? = try? j.decode("key")
```
```Swift
let value: String = j.decode("key").catch("sub-value")
```

---

### More Example
See the Alembic `Tests` for more examples.  
You can use playground that included in workspace :)

---

## Playground
1. Open Alembic.xcworkspace.
2. Build the Alembic for Mac.
3. Open playground in project navigator.
4. Enjoy the Alembic!

---

## Contribution
Welcome to fork and submit pull requests!!  

Before submitting pull request, please ensure you have passed the included tests.  
If your pull request including new function, please write test cases for it.  

---

## License  
Alembic is released under the MIT License.

---
