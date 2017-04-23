import class Foundation.NSNumber

public protocol Distillable {
    static func distil(json j: JSON) throws -> Self
}

extension JSON: Distillable {
    public static func distil(json j: JSON) throws -> JSON {
        return j
    }
}

extension String: Distillable {
    public static func distil(json j: JSON) throws -> String {
        return try cast(j)
    }
}

extension Int: Distillable {
    public static func distil(json j: JSON) throws -> Int {
        return try cast(j)
    }
}

extension Double: Distillable {
    public static func distil(json j: JSON) throws -> Double {
        return try cast(j)
    }
}

extension Float: Distillable {
    public static func distil(json j: JSON) throws -> Float {
        return try cast(j)
    }
}

extension Bool: Distillable {
    public static func distil(json j: JSON) throws -> Bool {
        return try cast(j)
    }
}

extension NSNumber: Distillable {
    public static func distil(json j: JSON) throws -> Self {
        return try cast(j)
    }
}

extension Int8: Distillable {
    public static func distil(json j: JSON) throws -> Int8 {
        return try NSNumber.distil(json: j).int8Value
    }
}

extension UInt8: Distillable {
    public static func distil(json j: JSON) throws -> UInt8 {
        return try NSNumber.distil(json: j).uint8Value
    }
}

extension Int16: Distillable {
    public static func distil(json j: JSON) throws -> Int16 {
        return try NSNumber.distil(json: j).int16Value
    }
}

extension UInt16: Distillable {
    public static func distil(json j: JSON) throws -> UInt16 {
        return try NSNumber.distil(json: j).uint16Value
    }
}

extension Int32: Distillable {
    public static func distil(json j: JSON) throws -> Int32 {
        return try NSNumber.distil(json: j).int32Value
    }
}

extension UInt32: Distillable {
    public static func distil(json j: JSON) throws -> UInt32 {
        return try NSNumber.distil(json: j).uint32Value
    }
}

extension Int64: Distillable {
    public static func distil(json j: JSON) throws -> Int64 {
        return try NSNumber.distil(json: j).int64Value
    }
}

extension UInt64: Distillable {
    public static func distil(json j: JSON) throws -> UInt64 {
        return try NSNumber.distil(json: j).uint64Value
    }
}

public extension RawRepresentable where Self: Distillable, RawValue: Distillable {
    static func distil(json j: JSON) throws -> Self {
        guard let value = try self.init(rawValue: .distil(json: j)) else {
            throw DistillError.typeMismatch(expected: Self.self, actual: j.raw, path: [])
        }
        return value
    }
}

extension Array where Element: Distillable {
    public static func distil(json j: JSON) throws -> [Element] {
        let arr: [Any] = try cast(j)
        return try arr.map { try JSON($0).distil() }
    }
}

extension Dictionary where Key == String, Value: Distillable {
    public static func distil(json j: JSON) throws -> [String: Value] {
        let dic: [String: Any] = try cast(j)
        var new = [String: Value](minimumCapacity: dic.count)
        try dic.forEach { try new.updateValue(JSON($1).distil(), forKey: $0) }
        return new
    }
}

private func cast<T>(_ j: JSON) throws -> T {
    guard let value = j.raw as? T else {
        throw DistillError.typeMismatch(expected: T.self, actual: j.raw, path: [])
    }
    return value
}
