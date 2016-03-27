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

let jsonObject2 = [
    "string_key": "string",
    "nested": ["int_key": 100],
    "array_key": [1, 2, 3, 4, 5],
]

let j = JSON(jsonObject2)
let string: String = try j <| "string_key"
let int: Int = try j <| ["nested", "int_key"]
let array: [Int] = try j <| "array_key"
let intFromArray: Int = try j <| ["array_key", 2]

let jsonObject3 = [
    "nested": [
        "int_key": 100,
        "array_key": [1, 2, 3, 4, 5]
    ]
]
do {
    let j = JSON(jsonObject3)
    let int: Int = try j <| ["nested", "int_key"]
    let intFromArray: Int = try j <| ["nested", "array_key", 2]
} catch {
    // Do error handling...
}

func color(fromHex hexString: String) -> UIColor { var hex: UInt32 = 0; let trimmedHex = hexString.stringByReplacingOccurrencesOfString("[^0-9a-fA-F]", withString: "", options: .RegularExpressionSearch); NSScanner(string: trimmedHex).scanHexInt(&hex); let divisor: CGFloat = 255; let r = CGFloat((hex & 0xFF0000) >> 16) / divisor; let g = CGFloat((hex & 0x00FF00) >> 8) / divisor; let b = CGFloat(hex & 0x0000FF) / divisor; return UIColor(red: r, green: g, blue: b, alpha: 1) }

func dateFromString(format: String) -> String -> NSDate? {
    return { dateString in
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = format
        return formatter.dateFromString(dateString)
    }
}

let jsonObject4 = [
    "time_stamp": [
        "2016-04-01 00:00:00",
        "2016-04-02 01:00:00",
        "2016-04-03 02:00:00",
        "2016-04-04 03:00:00",
        "2016-04-05 04:00:00",
    ]
]
let j4 = JSON(jsonObject4)
let timeStamp = (j4 <|? "time_stamp")([String]?)
    .filterNil()
    .map { s -> [NSDate] in
        let formatter = NSDateFormatter()
        formatter.locale = .systemLocale()
        formatter.timeZone = .localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return s.flatMap(formatter.dateFromString)
    }
    .catchUp([])
    .to([NSDate])


extension NSURL: Distillable {
    public static func distil(j: JSON) throws -> Self {
        guard let url = try self.init(string: j.distil()) else {
            throw DistilError.TypeMismatch(expected: NSURL.self, actual: j.raw)
        }
        return url
    }
}

struct Sample: Distillable {
    let string: String
    let int: Int?
    
    static func distil(j: JSON) throws -> Sample {
        return try Sample(
            string: j <| "string_key",
            int: j <|? "int_optional_key"
        )
    }
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



