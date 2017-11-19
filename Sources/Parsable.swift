import class Foundation.NSNumber
import let Foundation.kCFBooleanTrue
import let Foundation.kCFBooleanFalse

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

extension NSNumber: Parsable {
    public static func value(from json: JSON) throws -> Self {
        return try cast(json.rawValue)
    }
}

extension Bool: Parsable {
    public static func value(from json: JSON) throws -> Bool {
        let number = try NSNumber.value(from: json)
        if number === kCFBooleanTrue { return true }
        else if number === kCFBooleanFalse { return false }
        
        throw JSON.Error.typeMismatch(expected: Bool.self, actualValue: value, path: [])
    }
}

extension Double: Parsable {
    public static func value(from json: JSON) throws -> Double {
        return try castNotBooleanNumber(json.rawValue).doubleValue
    }
}

extension Float: Parsable {
    public static func value(from json: JSON) throws -> Float {
        let number = try castNotBooleanNumber(json.rawValue)
        let double = number.doubleValue
        guard abs(double) <= Double(Float.greatestFiniteMagnitude)
            else { throw JSON.Error.dataCorrupted(value: number, description: "The parsed number(\(number) does overflow in Float type.") }
        
        return .init(double)
    }
}

extension Int: Parsable {
    public static func value(from json: JSON) throws -> Int {
        return try castNotBooleanNumber(json.rawValue).intValue
    }
}

extension UInt: Parsable {
    public static func value(from json: JSON) throws -> UInt {
        return try castNotBooleanNumber(json.rawValue).uintValue
    }
}

extension Int8: Parsable {
    public static func value(from json: JSON) throws -> Int8 {
        return try castNotBooleanNumber(json.rawValue).int8Value
    }
}

extension Int16: Parsable {
    public static func value(from json: JSON) throws -> Int16 {
        return try castNotBooleanNumber(json.rawValue).int16Value
    }
}

extension Int32: Parsable {
    public static func value(from json: JSON) throws -> Int32 {
        return try castNotBooleanNumber(json.rawValue).int32Value
    }
}

extension Int64: Parsable {
    public static func value(from json: JSON) throws -> Int64 {
        return try castNotBooleanNumber(json.rawValue).int64Value
    }
}

extension UInt8: Parsable {
    public static func value(from json: JSON) throws -> UInt8 {
        return try castNotBooleanNumber(json.rawValue).uint8Value
    }
}

extension UInt16: Parsable {
    public static func value(from json: JSON) throws -> UInt16 {
        return try castNotBooleanNumber(json.rawValue).uint16Value
    }
}

extension UInt32: Parsable {
    public static func value(from json: JSON) throws -> UInt32 {
        return try castNotBooleanNumber(json.rawValue).uint32Value
    }
}

extension UInt64: Parsable {
    public static func value(from json: JSON) throws -> UInt64 {
        return try castNotBooleanNumber(json.rawValue).uint64Value
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

private func castNotBooleanNumber(_ value: Any) throws -> NSNumber {
    guard let number = value as? NSNumber, number !== kCFBooleanTrue && number !== kCFBooleanFalse else {
        throw JSON.Error.typeMismatch(expected: NSNumber.self, actualValue: value, path: [])
    }
    
    return number
}
