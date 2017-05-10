public extension JSON {
    public enum Error: Swift.Error {
        case missing(path: JSON.Path)
        case typeMismatch(value: Any, expected: Any.Type, path: JSON.Path)
        case filtered(value: Any?, type: Any.Type)
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
        case let .typeMismatch(value: value, expected: expected, path: path):
            return "typeMismatch(value: \(value), expected: \(expected), path: \(path))"
        case let .filtered(value: value, type: type):
            return "filteredValue(value: \(String(describing: value)), type: \(type))"
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
