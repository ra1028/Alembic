public enum DecodeError: Error {
    case missing(path: JSON.Path)
    case typeMismatch(value: Any, expected: Any.Type, path: JSON.Path)
    case filtered(value: Any, type: Any.Type)
    case serializeFailed(value: Any)
}

// MARK: - CustomStringConvertible

extension DecodeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .missing(path: path):
            return "missing(path: \(path))"
        case let .typeMismatch(value: value, expected: expected, path: path):
            return "typeMismatch(value: \(value), expected: \(expected), path: \(path))"
        case let .filtered(value: value, type: type):
            return "filteredValue(value: \(value), type: \(type))"
        case let .serializeFailed(value: value):
            return "serializeFailed(value: \(value))"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DecodeError: CustomDebugStringConvertible {    
    public var debugDescription: String {
        return description
    }
}
