public enum DecodeError: Error {
    case missingPath(Path)
    case typeMismatch(expected: Any.Type, actualValue: Any, path: Path)
    case filtered(value: Any)
    case serializeFailed(raw: Any)
}

// MARK: - CustomStringConvertible

extension DecodeError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .missingPath(path):
            return "missingPath(\(path))"
        case let .typeMismatch(expected: expected, actualValue: actualValue, path: path):
            return "typeMismatch(expected: \(expected), actualValue: \(actualValue), path: \(path))"
        case let .filtered(value: value):
            return "filteredValue(value: \(value))"
        case let .serializeFailed(raw: raw):
            return "serializeFailed(raw: \(raw))"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension DecodeError: CustomDebugStringConvertible {    
    public var debugDescription: String {
        return description
    }
}
