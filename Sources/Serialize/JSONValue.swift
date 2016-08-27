//
//  JSONValue.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/14/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

public struct JSONValue {
    let value: Any
    
    fileprivate init(value: Any) {
        self.value = value
    }
}

public extension JSONValue {
    static var null: JSONValue {
        return JSONValue(value: NSNull())
    }
    
    init(_ number: NSNumber) {
        value = number
    }
    
    init(_ string: String) {
        value = string
    }
    
    init<T: JSONValueConvertible>(_ optionalValue: Optional<T>) {
        value = optionalValue.map { $0.jsonValue.value } ?? NSNull()
    }
    
    init<T: JSONValueConvertible>(_ array: [T]) {
        value = array.map { $0.jsonValue.value }
    }
    
    init<T: JSONValueConvertible>(_ dictionary: [String: T]) {
        var new = [String: Any](minimumCapacity: dictionary.count)
        dictionary.forEach { new[$0] = $1.jsonValue.value }
        value = new
    }
}

extension JSONValue: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self.init(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(value)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension JSONValue: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(NSNumber(value: value))
    }
}

extension JSONValue: ExpressibleByFloatLiteral {
    public init(floatLiteral value: Float) {
        self.init(NSNumber(value: value))
    }
}

extension JSONValue: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self.init(NSNumber(value: value))
    }
}

extension JSONValue: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = JSONValue.null
    }
}

extension JSONValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONValueConvertible...) {
        let array = elements.map { $0.jsonValue.value }
        self.init(value: array)
    }
}

extension JSONValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, JSONValueConvertible)...) {
        var dictionary = [String: Any](minimumCapacity: elements.count)
        elements.forEach { dictionary[$0] = $1.jsonValue.value }
        self.init(value: dictionary)
    }
}
