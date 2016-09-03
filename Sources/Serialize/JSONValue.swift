//
//  JSONValue.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/14/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
public struct JSONValue {
    let value: AnyObject
    
    private init(value: AnyObject) {
        self.value = value
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
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
        var new = [String: AnyObject](minimumCapacity: dictionary.count)
        dictionary.forEach { new[$0] = $1.jsonValue.value }
        value = new
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: StringLiteralConvertible {
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

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self.init(NSNumber(integer: value))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: FloatLiteralConvertible {
    public init(floatLiteral value: Float) {
        self.init(NSNumber(float: value))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: BooleanLiteralConvertible {
    public init(booleanLiteral value: Bool) {
        self.init(NSNumber(bool: value))
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: NilLiteralConvertible {
    public init(nilLiteral: ()) {
        self = JSONValue.null
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSONValueConvertible...) {
        let array = elements.map { $0.jsonValue.value }
        self.init(value: array)
    }
}

@available(*, deprecated, message="Serializing objects to JSON data or string will be obsolete on Swift3 support version")
extension JSONValue: DictionaryLiteralConvertible {
    public init(dictionaryLiteral elements: (String, JSONValueConvertible)...) {
        var dictionary = [String: AnyObject](minimumCapacity: elements.count)
        elements.forEach { dictionary[$0] = $1.jsonValue.value }
        self.init(value: dictionary)
    }
}