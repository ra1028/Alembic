import Foundation

public protocol Distillable {
    static func distil(j: JSON) throws -> Self
}

extension String: Distillable {
    public static func distil(j: JSON) throws -> String {
        return try cast(j)
    }
}

extension Int: Distillable {
    public static func distil(j: JSON) throws -> Int {
        return try cast(j)
    }
}

extension Double: Distillable {
    public static func distil(j: JSON) throws -> Double {
        return try cast(j)
    }
}

extension Float: Distillable {
    public static func distil(j: JSON) throws -> Float {
        return try cast(j)
    }
}

extension Bool: Distillable {
    public static func distil(j: JSON) throws -> Bool {
        return try cast(j)
    }
}

extension NSNumber: Distillable {
    public static func distil(j: JSON) throws -> Self {
        return try cast(j)
    }
}
extension Int8: Distillable {
    public static func distil(j: JSON) throws -> Int8 {
        return try NSNumber.distil(j).charValue
    }
}
extension UInt8: Distillable {
    public static func distil(j: JSON) throws -> UInt8 {
        return try NSNumber.distil(j).unsignedCharValue
    }
}
extension Int16: Distillable {
    public static func distil(j: JSON) throws -> Int16 {
        return try NSNumber.distil(j).shortValue
    }
}
extension UInt16: Distillable {
    public static func distil(j: JSON) throws -> UInt16 {
        return try NSNumber.distil(j).unsignedShortValue
    }
}
extension Int32: Distillable {
    public static func distil(j: JSON) throws -> Int32 {
        return try NSNumber.distil(j).intValue
    }
}
extension UInt32: Distillable {
    public static func distil(j: JSON) throws -> UInt32 {
        return try NSNumber.distil(j).unsignedIntValue
    }
}
extension Int64: Distillable {
    public static func distil(j: JSON) throws -> Int64 {
        return try NSNumber.distil(j).longLongValue
    }
}
extension UInt64: Distillable {
    public static func distil(j: JSON) throws -> UInt64 {
        return try NSNumber.distil(j).unsignedLongLongValue
    }
}

public extension RawRepresentable where Self: Distillable, RawValue: Distillable {
    static func distil(j: JSON) throws -> Self {
        guard let value = try self.init(rawValue: RawValue.distil(j)) else {
            throw DistilError.TypeMismatch(expectedType: Self.self, actual: j.raw)
        }
        return value
    }
}

private func cast<T>(j: JSON) throws -> T {
    guard let value = j.raw as? T else {
        throw DistilError.TypeMismatch(expectedType: T.self, actual: j.raw)
    }
    return value
}