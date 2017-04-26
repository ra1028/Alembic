public protocol DecodedProtocol {
    associatedtype Value
    
    func value() throws -> Value
}

public extension DecodedProtocol {
    func map<T>(_ transform: @escaping (Value) throws -> T) -> ThrowableDecoded<T> {
        return .init { try transform(self.value()) }
    }
    
    func flatMap<T: DecodedProtocol>(_ transform: @escaping (Value) throws -> T) -> ThrowableDecoded<T.Value> {
        return .init { try self.map(transform).value().value() }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> T?) -> ThrowableDecoded<T> {
        return .init {
            let optional = try self.map(transform).value()
            guard let value = optional else { throw DecodeError.filtered(value: optional as Any, type: Value.self) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> ThrowableDecoded<Value> {
        return .init {
            let value = try self.value()
            guard try predicate(value) else { throw DecodeError.filtered(value: value, type: Value.self) }
            return value
        }
    }
}

public extension DecodedProtocol where Value: OptionalProtocol {
    func filterNil() -> ThrowableDecoded<Value.Wrapped> {
        return .init { try self.filter { $0.optional != nil }.value().optional! }
    }
}
