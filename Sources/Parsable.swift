import class Foundation.NSNumber
import struct Foundation.Decimal

public protocol Parsable {
    static func value(from json: JSON) throws -> Self
}

extension JSON: Parsable {
    public static func value(from json: JSON) throws -> JSON {
        return json
    }
}

extension String: Parsable {
    public static func value(from json: JSON) throws -> String {
        return try cast(json.rawValue)
    }
}

extension Bool: Parsable {
    public static func value(from json: JSON) throws -> Bool {
        return try cast(json.rawValue)
    }
}

extension NSNumber: Parsable {
    public static func value(from json: JSON) throws -> Self {
        return try cast(json.rawValue)
    }
}

extension Double: Parsable {
    public static func value(from json: JSON) throws -> Double {
        return try NSNumber.value(from: json).doubleValue
    }
}

extension Float: Parsable {
    public static func value(from json: JSON) throws -> Float {
        let number = try NSNumber.value(from: json)
        let double = number.doubleValue
        guard Swift.abs(double) <= Double(Float.greatestFiniteMagnitude)
            else { throw JSON.Error.dataCorrupted(value: number, description: "The parsed number(\(number) does overflow in Float type.") }
        
        return .init(double)
    }
}

extension Int: Parsable {
    public static func value(from json: JSON) throws -> Int {
        return try NSNumber.value(from: json).intValue
    }
}

extension UInt: Parsable {
    public static func value(from json: JSON) throws -> UInt {
        return try NSNumber.value(from: json).uintValue
    }
}

extension Int8: Parsable {
    public static func value(from json: JSON) throws -> Int8 {
        return try NSNumber.value(from: json).int8Value
    }
}

extension Int16: Parsable {
    public static func value(from json: JSON) throws -> Int16 {
        return try NSNumber.value(from: json).int16Value
    }
}

extension Int32: Parsable {
    public static func value(from json: JSON) throws -> Int32 {
        return try NSNumber.value(from: json).int32Value
    }
}

extension Int64: Parsable {
    public static func value(from json: JSON) throws -> Int64 {
        return try NSNumber.value(from: json).int64Value
    }
}

extension UInt8: Parsable {
    public static func value(from json: JSON) throws -> UInt8 {
        return try NSNumber.value(from: json).uint8Value
    }
}

extension UInt16: Parsable {
    public static func value(from json: JSON) throws -> UInt16 {
        return try NSNumber.value(from: json).uint16Value
    }
}

extension UInt32: Parsable {
    public static func value(from json: JSON) throws -> UInt32 {
        return try NSNumber.value(from: json).uint32Value
    }
}

extension UInt64: Parsable {
    public static func value(from json: JSON) throws -> UInt64 {
        return try NSNumber.value(from: json).uint64Value
    }
}

extension Decimal: Parsable {
    public static func value(from json: JSON) throws -> Decimal {
        return try NSNumber.value(from: json).decimalValue
    }
}

public extension RawRepresentable where Self: Parsable, RawValue: Parsable {
    static func value(from json: JSON) throws -> Self {
        guard let value = try self.init(rawValue: .value(from: json)) else {
            throw JSON.Error.typeMismatch(expected: Self.self, actualValue: json.rawValue, path: [])
        }
        return value
    }
}

public extension Array where Element: Parsable {
    static func value(from json: JSON) throws -> [Element] {
        let array: [Any] = try cast(json.rawValue)
        return try array.map { try JSON($0).value() }
    }
}

public extension Dictionary where Key == String, Value: Parsable {
    static func value(from json: JSON) throws -> [String: Value] {
        let rawDictionary: [String: Any] = try cast(json.rawValue)
        return try rawDictionary.mapValues { try JSON($0).value() }
    }
}

private func cast<T>(_ value: Any) throws -> T {
    guard let castedValue = value as? T else {
        throw JSON.Error.typeMismatch(expected: T.self, actualValue: value, path: [])
    }
    return castedValue
}
