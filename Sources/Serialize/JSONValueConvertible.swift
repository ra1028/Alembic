//
//  JSONValueConvertible.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/15/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
public protocol JSONValueConvertible {
    var jsonValue: JSONValue { get }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return self
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension String: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(self)
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Int: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(integer: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Double: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(double: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Float: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(float: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Bool: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(bool: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension NSNumber: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(self)
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Int8: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(char: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension UInt8: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(unsignedChar: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Int16: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(short: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension UInt16: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(unsignedShort: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Int32: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(int: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension UInt32: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(unsignedInt: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension Int64: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(longLong: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension UInt64: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return JSONValue(NSNumber(unsignedLongLong: self))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
public extension RawRepresentable where Self: JSONValueConvertible, RawValue: JSONValueConvertible {
    public var jsonValue: JSONValue {
        return rawValue.jsonValue
    }
}