public extension JSON {
    public enum Error: Swift.Error {
        case missing(path: JSON.Path)
        case typeMismatch(expected: Any.Type, actualValue: Any, path: JSON.Path)
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
        case let .typeMismatch(expected: expected, actualValue: actualValue, path: path):
            return "typeMismatch(expected: \(expected), actualValue: \(actualValue), path: \(path))"
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
