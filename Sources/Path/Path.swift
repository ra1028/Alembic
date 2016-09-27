//
//  Path.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public struct Path {
    let paths: [PathElement]
    
    public init(_ path: PathElement) {
        paths = [path]
    }
    
    public init(_ paths: [PathElement]) {
        self.paths = paths
    }
}

// MARK: - Equatable

extension Path: Equatable {
    public static func == (lhs: Path, rhs: Path) -> Bool {
        return lhs.paths == rhs.paths
    }
    
    public static func + (lhs: Path, rhs: Path) -> Path {
        return Path(lhs.paths + rhs.paths)
    }
}

// MARK: - CustomStringConvertible

extension Path: CustomStringConvertible {
    public var description: String {
        return "Path(\(paths))"
    }
}

// MARK: - CustomDebugStringConvertible

extension Path: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByStringLiteral

extension Path: ExpressibleByStringLiteral {
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

// MARK: - ExpressibleByIntegerLiteral

extension Path: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.init(.index(value))
    }
}

// MARK: - ExpressibleByArrayLiteral

extension Path: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: PathElement...) {
        self.init(elements)
    }
}
