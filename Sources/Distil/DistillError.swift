//
//  DistillError.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public enum DistillError: Error {
    case missingPath(JSONPath)
    case typeMismatch(expected: Any.Type, actual: Any)
    case filteredValue(type: Any.Type, value: Any)
}

// MARK: - CustomStringConvertible

extension DistillError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .missingPath(path):
            return "MissingPath(\(path))"
        case let .typeMismatch(expected, actual):
            return "TypeMismatch(expected: \(expected), actual: \(type(of: actual))(\(actual)))"
        case let .filteredValue(type, value):
            return "FilteredValue(type: \(type), value: \(value))"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DistillError: CustomDebugStringConvertible {    
    public var debugDescription: String {
        return description
    }
}
