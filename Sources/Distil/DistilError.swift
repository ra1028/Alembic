//
//  DistilError.swift
//  Alembic
//
//  Created by Ryo Aoyama on 3/13/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

public enum DistilError: ErrorType {
    case MissingPath(JSONPath)
    case TypeMismatch(expected: Any.Type, actual: AnyObject)
    case FilteredValue(type: Any.Type, value: Any)
}

extension DistilError: CustomDebugStringConvertible {    
    public var debugDescription: String {
        switch self {
        case let .MissingPath(path):
            return "MissingPath(\(path))"
        case let .TypeMismatch(expected, actual):
            return "TypeMismatch(expected: \(expected), actual: \(actual.dynamicType)(\(actual)))"
        case let .FilteredValue(type, value):
            return "FilteredValue(type: \(type), value: \(value))"
        }
    }
}