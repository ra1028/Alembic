public enum DistillError: Error {
    case missingPath(Path)
    case typeMismatch(expected: Any.Type, actual: Any, path: Path)
    case filteredValue(type: Any.Type, value: Any)
    case serializeFailed(with: Any)
}

// MARK: - CustomStringConvertible

extension DistillError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .missingPath(path):
            return "missingPath(\(path))"
        case let .typeMismatch(expected: expected, actual: actual, path: path):
            return "typeMismatch(expected: \(expected), actual: \(type(of: actual))(\(actual)), path: \(path))"
        case let .filteredValue(type: type, value: value):
            return "filteredValue(type: \(type), value: \(value))"
        case let .serializeFailed(with: with):
            return "serializeFailed(with: \(type(of: with))(\(with)))"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DistillError: CustomDebugStringConvertible {    
    public var debugDescription: String {
        return description
    }
}
