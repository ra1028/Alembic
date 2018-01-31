public protocol ParserProtocol {
    associatedtype Value
    
    var path: JSON.Path { get }
    
    func value() throws -> Value
}

public extension ParserProtocol {
    func map<T>(_ transform: @escaping (Value) throws -> T) -> JSON.ThrowParser<T> {
        return .init(path: path) {
            let value = try self.value()
            return try transform(value)
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> JSON.Parser<T>) -> JSON.ThrowParser<T> {
        return _flatMap(transform)
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> JSON.ThrowParser<T>) -> JSON.ThrowParser<T> {
        return _flatMap(transform)
    }
    
    func filterMap<T>(_ transform: @escaping (Value) throws -> T?) -> JSON.ThrowParser<T> {
        return map {
            let optional = try transform($0)
            guard let value = optional else { throw JSON.Error.unexpected(value: optional, path: self.path) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> JSON.ThrowParser<Value> {
        return map {
            guard try predicate($0) else { throw JSON.Error.unexpected(value: $0, path: self.path) }
            return $0
        }
    }
}

public extension ParserProtocol where Value: OptionalProtocol {
    func filterNil() -> JSON.ThrowParser<Value.Wrapped> {
        return map {
            let optional = $0.optional
            guard let value = optional else { throw JSON.Error.unexpected(value: optional, path: self.path) }
            return value
        }
    }
}

private extension ParserProtocol {
    @inline(__always)
    func _flatMap<T: ParserProtocol>(_ transform: @escaping (Value) throws -> T) -> JSON.ThrowParser<T.Value> {
        return map { try transform($0).value() }
    }
}
