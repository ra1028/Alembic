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
        return try cast(from: json)
    }
}

extension Bool: Parsable {
    public static func value(from json: JSON) throws -> Bool {
        return try cast(from: json)
    }
}

extension NSNumber: Parsable {
    public static func value(from json: JSON) throws -> Self {
        return try cast(from: json)
    }
}

extension Double: Parsable {
    public static func value(from json: JSON) throws -> Double {
        return try castNumber(from: json, \.doubleValue)
    }
}

extension Float: Parsable {
    public static func value(from json: JSON) throws -> Float {
        guard let double = try? castNumber(from: json, \.doubleValue) else { throw JSON.Error.typeMismatch(expected: Float.self, actualValue: json.rawValue, path: []) }
        
        guard Swift.abs(double) <= Double(Float.greatestFiniteMagnitude)
            else { throw JSON.Error.dataCorrupted(value: json.rawValue, description: "The parsed value(\(json.rawValue) does overflow in Float type.") }
        
        return .init(double)
    }
}

extension Int: Parsable {
    public static func value(from json: JSON) throws -> Int {
        return try castNumber(from: json, \.intValue)
    }
}

extension UInt: Parsable {
    public static func value(from json: JSON) throws -> UInt {
        return try castNumber(from: json, \.uintValue)
    }
}

extension Int8: Parsable {
    public static func value(from json: JSON) throws -> Int8 {
        return try castNumber(from: json, \.int8Value)
    }
}

extension Int16: Parsable {
    public static func value(from json: JSON) throws -> Int16 {
        return try castNumber(from: json, \.int16Value)
    }
}

extension Int32: Parsable {
    public static func value(from json: JSON) throws -> Int32 {
        return try castNumber(from: json, \.int32Value)
    }
}

extension Int64: Parsable {
    public static func value(from json: JSON) throws -> Int64 {
        return try castNumber(from: json, \.int64Value)
    }
}

extension UInt8: Parsable {
    public static func value(from json: JSON) throws -> UInt8 {
        return try castNumber(from: json, \.uint8Value)
    }
}

extension UInt16: Parsable {
    public static func value(from json: JSON) throws -> UInt16 {
        return try castNumber(from: json, \.uint16Value)
    }
}

extension UInt32: Parsable {
    public static func value(from json: JSON) throws -> UInt32 {
        return try castNumber(from: json, \.uint32Value)
    }
}

extension UInt64: Parsable {
    public static func value(from json: JSON) throws -> UInt64 {
        return try castNumber(from: json, \.uint64Value)
    }
}

extension Decimal: Parsable {
    public static func value(from json: JSON) throws -> Decimal {
        return try castNumber(from: json, \.decimalValue)
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
        let array: [Any] = try cast(from: json)
        return try array.map { try JSON($0).value() }
    }
}

public extension Dictionary where Key == String, Value: Parsable {
    static func value(from json: JSON) throws -> [String: Value] {
        let rawDictionary: [String: Any] = try cast(from: json)
        return try rawDictionary.mapValues { try JSON($0).value() }
    }
}

private func cast<T>(from json: JSON) throws -> T {
    let rawValue = json.rawValue
    guard let value = rawValue as? T else {
        throw JSON.Error.typeMismatch(expected: T.self, actualValue: rawValue, path: [])
    }
    return value
}

private func castNumber<T>(from json: JSON, _ keyPath: KeyPath<NSNumber, T>) throws -> T {
    guard let number = try? NSNumber.value(from: json) else { return try cast(from: json) }
    return number[keyPath: keyPath]
}
