//
//  PathElement.swift
//  Alembic
//
//  Created by 青山 遼 on 2016/09/03.
//  Copyright © 2016年 Ryo Aoyama. All rights reserved.
//

import Foundation

public enum PathElement: Equatable {
    case key(String)
    case index(Int)
}

// MARK: - Equatable

public func == (lhs: PathElement, rhs: PathElement) -> Bool {
    switch (lhs, rhs) {
    case let (.key(lKey), .key(rKey)): return lKey == rKey
    case let (.index(lIndex), .index(rIndex)): return lIndex == rIndex
    default: return false
    }
}

// MARK: - CustomStringConvertible

extension PathElement: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .key(key): return "\(key)"
        case let .index(index): return "\(index)"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension PathElement: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

// MARK: - ExpressibleByStringLiteral

extension PathElement: ExpressibleByStringLiteral {
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

// MARK: - ExpressibleByIntegerLiteral

extension PathElement: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self = .index(value)
    }
}
