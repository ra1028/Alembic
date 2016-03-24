import UIKit
import Alembic

func hexColor(hexString: String) -> UIColor {
    var hex: UInt32 = 0
    let trimmedHex = hexString.stringByReplacingOccurrencesOfString("[^0-9a-fA-F]", withString: "", options: .RegularExpressionSearch)
    NSScanner(string: trimmedHex).scanHexInt(&hex)
    let divisor: CGFloat = 255
    let r = CGFloat((hex & 0xFF0000) >> 16) / divisor
    let g = CGFloat((hex & 0x00FF00) >> 8) / divisor
    let b = CGFloat(hex & 0x0000FF) / divisor
    return UIColor(red: r, green: g, blue: b, alpha: 1)
}

enum Sample: Int, Distillable {
    case A = 1
    case B = 2
    case C = 3
}

class Person: Distillable, Serializable {
    let firstName: String
    let lastName: String
    let age: Int
    let int64: Int64
    let height: Double
    let float: Float
    let bool: Bool
    let number: NSNumber
    let rawValue: AnyObject
    let nested: String
    let nestedDict: [String: String]
    let array: [String]
    let arrayOption: [String]?
    let dictionary: [String: Int]
    let dictionaryOption: [String: Int]?
    let url: NSURL
    
    required init(json j: JSON) throws {
        try (
            firstName = (j <| "first_name").filter { !$0.isEmpty },
            lastName = (j <| "last_name").filter { !$0.isEmpty },
            age = j <| "age",
            int64 = j <| "int64",
            height = j <| "height",
            float = j <| "float",
            bool = j <| "bool",
            number = j <| "number",
            rawValue = (j <| "raw_value")(JSON).raw,
            nested = j <| ["nested", "value"],
            nestedDict = j <| ["nested", "dict"],
            array = (j <| "array").filterEmpty(),
            arrayOption = j <|? "arrayOption",
            dictionary = (j <| "dictionary").filterEmpty(),
            dictionaryOption = j <|? "dictionaryOption",
            url = (j <| "url_string")
                .map(NSURL.init(string:))
                .filterNil()
        )
    }
    
    static func distil(j: JSON) throws -> Self {
        return try self.init(json: j)
    }
    
    func serialize() -> JSONObject {
        return [
            "first_name": firstName,
            "last_name": lastName,
            "age": age,
            "int64": int64,
            "height": height,
            "float": float,
            "bool": bool,
            "number": number,
            "raw_value": rawValue as! String,
            "nested": JSONValue([
                "value": JSONValue(nested),
                "dict": JSONValue(nestedDict)]),
            "array": JSONValue(array),
            "arrayOption": arrayOption.map(JSONValue.init) ?? .null,
            "dictionary": JSONValue(dictionary),
            "dictionaryOption": dictionaryOption.map(JSONValue.init) ?? .null,
            "url_string": url.absoluteString
        ]
    }
}
    
// decode example

do {
    let raw = "100"
    let int: Int = try JSON(raw).distil()
        .map { Int($0) }
        .filterNil()
} catch {
    "Trew the error :<"
}

do {
    let raw = 3
    let string: Sample = try JSON(raw).distil()
} catch(let e) {
    print(e)
}

do {
    let raw = ["1", "2", "3", "4", "5"]
    let array: [Int] = try JSON(raw).distil().map {
        $0.map { Int($0) }.flatMap{ $0 }
    }
} catch(let e) {
    e
}

do {
    let hexString = ["color": "012C57"]
    let color: UIColor = try (JSON(hexString) <| ("color")).map(hexColor)
} catch(let e) {
    e
}

do {
    let raw = [
        "nest1": [
            "nest2": [1, 2, 3, 4, 5]
        ]
    ]    
    let text: [Int] = try JSON(raw) <| ["nest1", "nest2"]
} catch(let e) {
    e
}

// error

do {
    let null = NSNull()
    let error: String = try JSON(null).distil()
} catch let e {
    e
}

// without error

let dateString = "2011-01-26T19:06:43Z"
let date: NSDate = JSON(dateString).distil(String)
    .map { s -> NSDate? in
        let format = "yyyy-MM-dd'T'HH:mm:ssZ"
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = format
        return formatter.dateFromString(s)
    }
    .filterNil()
    .catchUp(NSDate())

// JSON decode example

let json: [String: AnyObject] = [
    "first_name": "ABC",
    "last_name": "DEF",
    "age": 20,
    "int64": NSNumber(longLong: Int64.max),
    "height": 175.9,
    "float": 32.1 as Float,
    "bool": true,
    "number": NSNumber(long: 123456789),
    "raw_value": "RawValue",
    "nested": [
        "value": "The nested value",
        "dict": [ "key": "The nested value" ] as [String: AnyObject]
        ] as [String: AnyObject],
    "array": [ "123", "456" ] as [AnyObject],
    "arrayOption": NSNull(),
    "dictionary": [ "A": 1, "B": 2 ] as [String: AnyObject],
    // "dictionaryOption" key is missing
    "url_string": "https://github.com/ra1028"
]

do {
    let raw = [
        "nest": [1, 2, 3, 4, 5]
    ]
    let array: [Int] = try (JSON(raw) <| "nest")
} catch(let e) {
    e
}

do {
    let person: Person = try JSON(json).distil()
    let data = JSON.serializeToString(person)
} catch let e {
    e
}

let raw = [
    "people": [
        "count": 150
    ]
]
let string: String = (JSON(raw) <| ["people", "count"])
    .filter { $0 > 100 }
    .map { "\($0) counts" }
    .catchUp("")

do {
    let a: Int = try JSON(100).distil()
} catch(let e) {
    print(e)
}


do {
    let j = JSON(100)
    let a: String = try j.distil(Int).map { "\($0)$" }
} catch(let e) {
    print(e)
}

do {
    let json = "{\"a\": {\"b\": {\"c\": 150}}}"
    let j = try JSON(string: json)
    let int = try (j <| ["a", "b", "c"])(Int)
        .map { "\($0)" }
        .to(String)
    let optInt: Int? = try (j <| ["a", "b", "c"])(Int)
} catch(let e) {
    print(e)
}

extension NSURL: Distillable {
    public static func distil(j: JSON) throws -> Self {
        guard let url = try self.init(string: j.distil()) else {
            throw DistilError.TypeMismatch(expectedType: NSURL.self, actual: j.raw)
        }
        return url
    }
}

do {
    let json = [
        "a": [
            ["b": "https://github.com/ra1028"],
            ["c": "https://github.com/ra1028"],
            ["d": "https://github.com/ra1028"]
        ]
    ]
    let j = JSON(json)
    let url: NSURL = try j <| ["a", 0, "b"]
    let nested: [[String: NSURL]] = try (j <| "a")([JSON])
        .map { try $0.distil() }
} catch(let e) {
    e
}

let abJson = [
    ["A":
        [
            "https://github.com/ra1028",
            "https://github.com/ra1028",
            "https://github.com/ra1028"
        ]
    ],
    ["B":
        [
            // missing "C" key
            ["D": "HELLO"]
        ]
    ]
]
let abj = JSON(abJson)
let urlArray: [NSURL] = (abj <|? [0, "A"]).ensure([])
let error = (abj <|? [1, "B", 0, "C"]).ensure("").to(String)
let hello = (abj <|? [1, "B", 0, "D"]).ensure("").to(String)

do {
    let json = [
        "key1": [String: String](),
        "key2": NSNull()
    ]
    let j = JSON(json)
    let empty: [String: String] = try (j <| "key1").remapEmpty(["empty": "empty"])
    let nilArray: [String] = try (j <|? "key2").filterNil()
} catch let e {
    e
}
