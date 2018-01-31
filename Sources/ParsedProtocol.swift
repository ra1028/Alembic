public protocol ParsedProtocol {
    associatedtype Value
    
    var path: JSON.Path { get }
    
    func value() throws -> Value
}

public extension ParsedProtocol {
    func map<T>(_ transform: @escaping (Value) throws -> T) -> ThrowParsed<T> {
        return .init(path: path) {
            let value = try self.value()
            return try transform(value)
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Parsed<T>) -> ThrowParsed<T> {
        return _flatMap(transform)
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> ThrowParsed<T>) -> ThrowParsed<T> {
        return _flatMap(transform)
    }
    
    func filterMap<T>(_ transform: @escaping (Value) throws -> T?) -> ThrowParsed<T> {
        return map {
            let optional = try transform($0)
            guard let value = optional else { throw JSON.Error.unexpected(value: optional, path: self.path) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> ThrowParsed<Value> {
        return map {
            guard try predicate($0) else { throw JSON.Error.unexpected(value: $0, path: self.path) }
            return $0
        }
    }
}

public extension ParsedProtocol where Value: OptionalProtocol {
    func filterNil() -> ThrowParsed<Value.Wrapped> {
        return map {
            let optional = $0.optional
            guard let value = optional else { throw JSON.Error.unexpected(value: optional, path: self.path) }
            return value
        }
    }
}

private extension ParsedProtocol {
    @inline(__always)
    func _flatMap<T: ParsedProtocol>(_ transform: @escaping (Value) throws -> T) -> ThrowParsed<T.Value> {
        return map { try transform($0).value() }
    }
}
