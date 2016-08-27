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

extension JSONPath: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self.init(.key(value))
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(.key(value))
    }
    
    public init(stringLiteral value: String) {
        self.init(.key(value))
    }
}

extension JSONPath: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(.index(value))
    }
}

extension JSONPath: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: JSONPathElement...) {
        self.init(elements)
    }
}

// MARK: - JSONPathElement

public enum JSONPathElement: Equatable {
    case key(String)
    case index(Int)
}

// MARK: - Operators

public func == (lhs: JSONPathElement, rhs: JSONPathElement) -> Bool {
    switch (lhs, rhs) {
    case let (.key(lKey), .key(rKey)): return lKey == rKey
    case let (.index(lIndex), .index(rIndex)): return lIndex == rIndex
    default: return false
    }
}

// MARK: - CustomStringConvertible

extension JSONPathElement: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .key(key): return "\(key)"
        case let .index(index): return "\(index)"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension JSONPathElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - LiteralConvertible

extension JSONPathElement: ExpressibleByStringLiteral {
    public init(unicodeScalarLiteral value: String) {
        self = .key(value)
    }
    
    public init(extendedGraphemeClusterLiteral value: String) {
        self = .key(value)
    }
    
    public init(stringLiteral value: String) {
        self = .key(value)
    }
}

extension JSONPathElement: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}
