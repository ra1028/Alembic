//
//  JSONPath.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import Foundation

// MARK: - JSONPath

public struct JSONPath: Equatable {
    let paths: [JSONPathElement]
    
    public init(_ path: JSONPathElement) {
        paths = [path]
    }
    
    public init(_ paths: [JSONPathElement]) {
        self.paths = paths
    }
}

// MARK: - Operators

public func == (lhs: JSONPath, rhs: JSONPath) -> Bool {
    return lhs.paths == rhs.paths
}

public func + (lhs: JSONPath, rhs: JSONPath) -> JSONPath {
    return JSONPath(lhs.paths + rhs.paths)
}

// MARK: - CustomStringConvertible

extension JSONPath: CustomStringConvertible {
    public var description: String {
        return "JSONPath(\(paths))"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSONPath: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - LiteralConvertible

extension JSONPath: StringLiteralConvertible {
    public init(unicodeScalarLiteral value: String) {
        self.init(JSONPathElement(value))
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(JSONPathElement(value))
    }
    
    public init(stringLiteral value: String) {
        self.init(JSONPathElement(value))
    }
}

extension JSONPath: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self.init(JSONPathElement(value))
    }
}

extension JSONPath: ArrayLiteralConvertible {
    public init(arrayLiteral elements: JSONPathElement...) {
        self.init(elements)
    }
}

// MARK: - JSONPathElement

public struct JSONPathElement: Equatable {
    let value: AnyObject
    
    public init(_ value: String) {
        self.value = value
    }
    
    public init(_ value: Int) {
        self.value = value
    }
}

// MARK: - Operators

public func == (lhs: JSONPathElement, rhs: JSONPathElement) -> Bool {
    switch (lhs.value, rhs.value) {
    case let (lKey as String, rKey as String): return lKey == rKey
    case let (lIndex as Int, rIndex as Int): return lIndex == rIndex
    case (is String, is Int): return false
    case (is Int, is String): return false
    default: fatalError("JSONPathElement value allow String or Int type only")
    }
}

// MARK: - CustomStringConvertible

extension JSONPathElement: CustomStringConvertible {
    public var description: String {
        return "\(value)"
    }
}

// MARK: - CustomDebugStringConvertible

extension JSONPathElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - LiteralConvertible

extension JSONPathElement: StringLiteralConvertible {
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

extension JSONPathElement: IntegerLiteralConvertible {
    public init(integerLiteral value: Int) {
        self.init(value)
    }
}