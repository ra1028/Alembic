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

struct Person: Distillable {
    let firstName: String
    let lastName: String
    let age: Int
    let int64: Int64
    let height: Double
    let float: Float
    let bool: Bool
    let number: NSNumber
    let nested: String
    let array: [String]
    let dictionary: [String: Int]
    let url: NSURL
    
    static func distil(j: JSON) throws -> Person {
        return try Person(
            firstName: j.distil("first_name"),
            lastName: j.distil("last_name"),
            age: j.distil("age"),
            int64: j.distil("int64"),
            height: j.distil("height"),
            float: j.distil("float"),
            bool: j.distil("bool"),
            number: j.distil("number"),
            nested: j.distil(["nested", "value"]),
            array: j.distil("array"),
            dictionary: j.distil("dictionary"),
            url: j.distil("url_string")
                .map { NSURL(string: $0) }
                .filterNil()
        )
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
    let color: UIColor = try JSON(hexString).distil("color").map(hexColor)
} catch(let e) {
    e
}

do {
    let raw = [
        "nest1": [
            "nest2": [1, 2, 3, 4, 5]
        ]
    ]    
    let text: [Int] = try JSON(raw).distil(["nest1", "nest2"])
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
    .catchUp { _ in NSDate() }


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
    ],
    "array": ["123", "456"] as [AnyObject],
    "dictionary": [ "A": 1, "B": 2 ] as [String: AnyObject],
    "url_string": "http://example.com"
]

do {
    let raw = [
        "nest": [1, 2, 3, 4, 5]
    ]
    let array: [Int] = try JSON(raw).distil("nest")
} catch(let e) {
    e
}

do {
    let person: Person = try JSON(json).distil()
    print(person)
} catch {
    "Threw the error :<"
}

let raw = [
    "people": [
        "count": 150
    ]
]
let string: String = JSON(raw).distil(["people", "count"])
    .filter { $0 > 100 }
    .map { "\($0) counts" }
    .catchUp { _ in "" }

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
    let int = try JSON(string: json).distil(["a", "b", "c"])(Int)
        .map { "\($0)" }
        .to(String)
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
    let url = try j.distil(["a", 0, "b"]).to(NSURL)
} catch(let e) {
    print(e)
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
let urlArray: [NSURL] = abj.optional([0, "A"]).ensure([])
let error = abj.optional([1, "B", 0, "C"]).ensure("").to(String)
let hello = abj.optional([1, "B", 0, "D"]).ensure("").to(String)

do {
    let json = [
        "key1": [String: String](),
        "key2": NSNull()
    ]
    let j = JSON(json)
    let empty: [String: String] = try j.distil("key1").filterEmpty()
    let nilArray: [String] = try j.optional("key2").filterNil()
} catch let e {
    e
}
