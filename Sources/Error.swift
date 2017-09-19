public extension JSON {
    public enum Error: Swift.Error {
        case missing(path: Path)
        case typeMismatch(expected: Any.Type, actualValue: Any, path: Path)
        case unexpected(value: Any?, path: Path)
        case serializeFailed(value: Any)
        case custom(reason: String)
    }
}

// MARK: - CustomStringConvertible

extension JSON.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .missing(path: path):
            return "missing(path: \(path))"
            
        case let .typeMismatch(expected: expected, actualValue: actualValue, path: path):
            return "typeMismatch(expected: \(expected), actualValue: \(actualValue), path: \(path))"
            
        case let .unexpected(value: value, path: path):
            return "unexpected(value: \(String(describing: value)), path: \(path))"
            
        case let .serializeFailed(value: value):
            return "serializeFailed(value: \(value))"
            
        case let .custom(reason: reason):
            return "custom(reason: \(reason))"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension JSON.Error: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}
