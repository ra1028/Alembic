//
//  JSONValueConvertible.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/15/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public protocol JSONValueConvertible {
    func jsonValue() -> JSONValue
}

extension JSONValue: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return self
    }
}

extension String: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(self)
    }
}

extension Int: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(integer: self))
    }
}

extension Double: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(double: self))
    }
}

extension Float: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(float: self))
    }
}

extension Bool: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(bool: self))
    }
}

extension NSNumber: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(self)
    }
}

extension Int8: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(char: self))
    }
}

extension UInt8: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(unsignedChar: self))
    }
}

extension Int16: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(short: self))
    }
}

extension UInt16: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(unsignedShort: self))
    }
}

extension Int32: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(int: self))
    }
}

extension UInt32: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(unsignedInt: self))
    }
}

extension Int64: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(longLong: self))
    }
}

extension UInt64: JSONValueConvertible {
    public func jsonValue() -> JSONValue {
        return JSONValue(NSNumber(unsignedLongLong: self))
    }
}

public extension RawRepresentable where Self: JSONValueConvertible, RawValue: JSONValueConvertible {
    func jsonValue() -> JSONValue {
        return rawValue.jsonValue()
    }
}