
public enum DistilError: ErrorType {
    case MissingPath(JSONPath)
    case TypeMismatch(expectedType: Any.Type, actual: AnyObject)
    case FilteredValue(Any)
}


extension DistilError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .MissingPath(path):
            return "MissingPath(\(path))"
        case let .TypeMismatch(expected, actual):
            return "TypeMismatch(expectedType: \(expected), actual: \(actual.dynamicType)(\(actual)))"
        case let .FilteredValue(value):
            return "FilteredValue(\(value))"
        }
    }
}