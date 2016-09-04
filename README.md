<div align="center"><img src="Assets/Alembic_Logo.png" alt="Alembic" width="70%"></div></br>

<p align="center">
<a href="https://travis-ci.org/ra1028/Alembic"><img alt="Build Status" src="https://travis-ci.org/ra1028/Alembic.svg?branch=master"/></a>
<a href="https://developer.apple.com/swift"><img alt="Swift3" src="https://img.shields.io/badge/swift3-compatible-blue.svg?style=flat"/></a>
<a href="http://cocoadocs.org/docsets/Alembic"><img alt="Platform" src="https://img.shields.io/cocoapods/p/Alembic.svg?style=flat"/></a><br>
<a href="https://cocoapods.org/pods/Alembic"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/Alembic.svg"/></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-yellow.svg?style=flat"/></a>
<a href="https://github.com/apple/swift-package-manager"><img alt="Swift Package Manager" src="https://img.shields.io/badge/Swift%20Package%20Manager-compatible-green.svg"/></a>
<a href="https://github.com/ra1028/Alembic/blob/master/LICENSE"><img alt="Lincense" src="http://img.shields.io/badge/license-MIT-000000.svg?style=flat"/></a>  
</p>

<p align="center">
<H4 align="center">Functional JSON parsing</H4>
</p>  

---

## Contents
- [Overview](#overview)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  + [Initialization](#initialization)
  + [JSON parsing](#json-parsing)
  + [Nested objects parsing](#nested-objects-parsing)
  + [Optional objects parsing](#optional-objects-parsing)
  + [Custom value parsing](#custom-objects-parsing)
  + [Object mapping](#object-mapping)
  + [Value transformation](#value-transformation)
  + [Error handling](#error-handling)
- [Playground](#playground)
- [Contribution](#contribution)
- [License](#license)

---

A trait of __Alembic__ is to enable easy JSON parsing and transform it's value.  
Followings is simple example of json parsing.  

## Overview  
```Swift
let j = JSON(obj)
```
Value parsing
```Swift
let str1: String = try j.distil("str1")
let str2: String = try j <| "str2"
let str3: String = try j["str3"].distil()
```
```Swift
j.distil("str1").value { (str1: String) in ... }
(j < | "str2").value { (str2: String) in ... }
j["str3"].distil().value { (str3: String) in ... }
```
Object mapping

```Swift
let user: User = try j <| "user"

struct User: Distillable {
    let name: String
    let avatarUrl: URL

    static func distil(_ j: JSON) throws -> User {
        return try User(
            name: j <| "name",
            avatarUrl: (j <| "avatar_url").flatMap(URL.init(string:))
        )
    }
}
```

---

## Requirements
- Swift 3.0 / Xcode 8
- OS X 10.9 or later
- iOS 8.0 or later
- watchOS 2.0 or later
- tvOS 9.0 or later

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

### [CocoaSeeds](https://github.com/devxoul/CocoaSeeds)  
Add the following to your Seedfile:
```ruby
github "ra1028/Alembic", :files => "Sources/**/*.swift"
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
let j = JSON(jsonObject)
```
JSON from Data
```Swift
let j = try JSON(data: jsonData)
```
```Swift
let j = try JSON(data: jsonData, options: .allowFragments)
```
JSON from String  
```Swift
let j = try JSON(string: jsonString)
```
```Swift
let j = try JSON(
    string: jsonString,
    encoding: .utf8,
    allowLossyConversion: false,
    options: .allowFragments
)
```

### JSON parsing
To enable parsing, a class, struct, or enum just needs to implement the `Distillable` protocol.  
```Swift
public protocol Distillable {
    static func distil(_ j: JSON) throws -> Self
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
```Swift
let jsonObject = ["key": "string"]
let j = JSON(jsonObject)
```
```Swift
let string: String = try j.distil("key")  // "string"
```
```Swift
let string: String = try j <| "key"  // "string"
```
```Swift
let string: String = try j["key"].distil()  // "string"
```

__Tips__  
You can set the generic type as following:  
```Swift
let string = try j.distil("key").to(String.self)  // "string"
```
It's same if use operator or subscript.  

### Nested objects parsing
Supports parsing nested objects with keys and indexes.  
Keys and indexes can be summarized in the same array.  

__Example__
```Swift
let jsonObject = [
    "nested": ["array": [1, 2, 3, 4, 5]]
]
let j = JSON(jsonObject)
```
```Swift
let int: Int = try j.distil(["nested", "array", 2])  // 3        
```
```Swift
let int: Int = try j <| ["nested", "array", 2]  // 3  
```
```Swift
let int: Int = try j["nested", "array", 2].distil()  // 3  
let int: Int = try j["nested"]["array"][2].distil()  // 3  
```

__Tips__  
Syntax like [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON) is here:  
```Swift
let json = try JSON(data: jsonData)
let userName = try json[0]["user"]["name"].to(String.self)
```

### Optional objects parsing
Has functions to parsing optional objects.  
If the key is missing, returns nil.  

__Example__
```Swift
let jsonObject = [
    "nested": [:] // Nested key is nothing...
]
let j = JSON(jsonObject)
```
```Swift
let int: Int? = try j.option(["nested", "key"])  // nil
```
```Swift
let int: Int? = try j <|? ["nested", "key"]  // nil
```
```Swift
let int: Int? = try j["nested", "key"].option()  // nil
let int: Int? = try j["nested"]["key"].option()  // nil
```

### Custom value parsing
If implement `Distillable` protocol to existing classes like `URL`, it be able to parse from JSON.  

__Example__
```Swift
let jsonObject = ["key": "http://example.com"]
let j = JSON(jsonObject)
```
```Swift
let url: URL = try j <| "key"  // http://example.com

extension URL: Distillable {
    public static func distil(_ j: JSON) throws -> URL {
        return try j.distil().flatMap(self.init(string:))
    }
}
```

### Object mapping  
To mapping your models, need confirm to the `Distillable` protocol.  
Then, parse the objects from JSON to all your model properties.  

__Example__
```Swift
let jsonObject = [
    "key": [
        "string_key": "string",
        "option_int_key": NSNull()
    ]
]
let j = JSON(jsonObject)
```
```Swift
let sample: Sample = try j <| "key"  // Sample

struct Sample: Distillable {
    let string: String
    let int: Int?

    static func distil(_ j: JSON) throws -> Sample {
        return try Sample(
            string: j <| "string_key",
            int: j <|? "option_int_key"
        )
    }
}
```

### Value transformation
Alembic supports functional value transformation during the parsing process like `String` -> `Date`.  
Functions that extract value from JSON are possible to return `Distillate` object.  
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
throw DistillError.filteredValue</td>
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
throw DistillError.filteredValue.</td>
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
<td>filterNil()</td>
<td>If the value is nil,<br>
throw DistillError.filteredValue.</td>
<td>Value.Wrapped</td>
<td>throw</td>
</tr>

<tr>
<td>replaceEmpty(Value)</td>
<td>If the value is empty of CollectionType, replace it.</td>
<td>Value</td>
<td>throw</td>
</tr>

<tr>
<td>replaceEmpty(() throws -> Value)</td>
<td>If the value is empty of CollectionType, replace it.</td>
<td>Value</td>
<td>throw</td>
</tr>

<tr>
<td>filterEmpty()</td>
<td>If the value is empty of CollectionType,<br>
throw DistillError.filteredValue.</td>
<td>Value</td>
<td>throw</td>
</tr>

</tbody>
</table>

__Example__
```Swift
let jsonObject = ["time_string": "2016-04-01 00:00:00"]
let j = JSON(jsonObject)
```
function
```Swift
let date: Date = j.distil("time_string", to: String.self)  // "Apr 1, 2016, 12:00 AM"
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
let value: String = try j.distil("number", to: Int.self).map { "Number \($0)" }
let value: String = try (j <| "number")(Int.self).map { "Number \($0)" }
let value: String = try j["number"].distil(to: Int.self).map { "Number \($0)" }
```

You can create `Distillate` by `Distillate.filter`, `Distillate.error(error)` and `Distillate.just(value)`.  
It's provide more convenience to value-transformation.  
Example:  

```Swift
struct FindAppleError: Error {}

let message: String = try j.distil("number_of_apples", to: Int.self)
    .flatMap { count -> Distillate<String> in
        count > 0 ? .just("\(count) apples found!!") : .filter
    }
    .flatMapError { _ in .error(FindAppleError()) }
    .catch { error in "Anything not found... | Error: \(error)" }
```

Alembic allows you to receive a value functinally as following.  
```Swift
let jsonObject = ["user": ["name": "john doe"]]
let j = JSON(jsonObject)
```
```Swift
j.distil(["user", "name"], to: String.self)
    .map { name in "User name is \(name)" }
    .value { message in
        print(message)
    }
    .error { error in
        // Do error handling
    }
```

### Error handling
Alembic has simple error handling designs as following.  

__DistillError__
- missingPath(Path)  
- typeMismatch(expected: Any.Type, actual: Any)  
- filteredValue(type: Any.Type, value: Any)  

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
try j.distil(path)<br>
try j <| path<br>
try j[path].distil()<br>
</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try j.option(path)<br>
try j <|? path<br>
try j[path].option()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>throw</td>
<td>throw</td>
</tr>

<tr>
<td>
try? j.distil(path)<br>
try? j <| path<br>
try? j[path].distil()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

<tr>
<td>
try? j.option(path)<br>
try? j <|? path<br>
try? j[path].option()<br>
</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
<td>nil</td>
</tr>

</tbody>
</table>

__Don't wanna handling the error?__  
If you don't care about error handling, use `try?` or `j.distil("key").catch(value)`.  
```Swift
let value: String? = try? j.distil("key")
```
```Swift
let value: String = j.distil("key").catch("sub-value")
```

---

### More Example
See the Alembic `Tests` for more examples.  
If you want to try Alembic, use Alembic Playground :)

---

## Playground
1. Open Alembic.xcworkspace.
2. Build the Alembic for Mac.
3. Open Alembic playground in project navigator.
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
