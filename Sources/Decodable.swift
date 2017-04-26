import class Foundation.NSNumber

public protocol Decodable {
    static func value(from json: JSON) throws -> Self
}

extension JSON: Decodable {
    public static func value(from json: JSON) throws -> JSON {
        return json
    }
}

extension String: Decodable {
    public static func value(from json: JSON) throws -> String {
        return try cast(json.rawValue)
    }
}

extension Int: Decodable {
    public static func value(from json: JSON) throws -> Int {
        return try cast(json.rawValue)
    }
}

extension Double: Decodable {
    public static func value(from json: JSON) throws -> Double {
        return try cast(json.rawValue)
    }
}

extension Float: Decodable {
    public static func value(from json: JSON) throws -> Float {
        return try cast(json.rawValue)
    }
}

extension Bool: Decodable {
    public static func value(from json: JSON) throws -> Bool {
        return try cast(json.rawValue)
    }
}

extension NSNumber: Decodable {
    public static func value(from json: JSON) throws -> Self {
        return try cast(json.rawValue)
    }
}

extension Int8: Decodable {
    public static func value(from json: JSON) throws -> Int8 {
        return try NSNumber.value(from: json).int8Value
    }
}

extension UInt8: Decodable {
    public static func value(from json: JSON) throws -> UInt8 {
        return try NSNumber.value(from: json).uint8Value
    }
}

extension Int16: Decodable {
    public static func value(from json: JSON) throws -> Int16 {
        return try NSNumber.value(from: json).int16Value
    }
}

extension UInt16: Decodable {
    public static func value(from json: JSON) throws -> UInt16 {
        return try NSNumber.value(from: json).uint16Value
    }
}

extension Int32: Decodable {
    public static func value(from json: JSON) throws -> Int32 {
        return try NSNumber.value(from: json).int32Value
    }
}

extension UInt32: Decodable {
    public static func value(from json: JSON) throws -> UInt32 {
        return try NSNumber.value(from: json).uint32Value
    }
}

extension Int64: Decodable {
    public static func value(from json: JSON) throws -> Int64 {
        return try NSNumber.value(from: json).int64Value
    }
}

extension UInt64: Decodable {
    public static func value(from json: JSON) throws -> UInt64 {
        return try NSNumber.value(from: json).uint64Value
    }
}

public extension RawRepresentable where Self: Decodable, RawValue: Decodable {
    static func value(from json: JSON) throws -> Self {
        guard let value = try self.init(rawValue: .value(from: json)) else {
            throw DecodeError.typeMismatch(value: json.rawValue, expected: Self.self, path: [])
        }
        return value
    }
}

extension Array where Element: Decodable {
    public static func value(from json: JSON) throws -> [Element] {
        let array: [Any] = try cast(json.rawValue)
        return try array.map { try JSON($0).value() }
    }
}

extension Dictionary where Key == String, Value: Decodable {
    public static func value(from json: JSON) throws -> [String: Value] {
        let rawDictionary: [String: Any] = try cast(json.rawValue)
        var dictionary = [String: Value](minimumCapacity: rawDictionary.count)
        try rawDictionary.forEach { try dictionary.updateValue(JSON($1).value(), forKey: $0) }
        return dictionary
    }
}

private func cast<T>(_ value: Any) throws -> T {
    guard let castedValue = value as? T else {
        throw DecodeError.typeMismatch(value: value, expected: T.self, path: [])
    }
    return castedValue
}
