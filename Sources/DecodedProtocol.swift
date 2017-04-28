public protocol DecodedProtocol {
    associatedtype Value
    
    func value() throws -> Value
}

public extension DecodedProtocol {
    func map<T>(_ transform: @escaping (Value) throws -> T) -> ThrowableDecoded<T> {
        return .init {
            do {
                let value = try *self
                return try transform(value)
            } catch let error {
                throw error
            }
        }
    }
    
    func flatMap<T: DecodedProtocol>(_ transform: @escaping (Value) throws -> T) -> ThrowableDecoded<T.Value> {
        return map { try *transform($0) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> T?) -> ThrowableDecoded<T> {
        return map {
            let optional = try transform($0)
            guard let value = optional else { throw DecodeError.filtered(value: optional as Any, type: T.self) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> ThrowableDecoded<Value> {
        return .init {
            let value = try *self
            guard try predicate(value) else { throw DecodeError.filtered(value: value, type: Value.self) }
            return value
        }
    }
}

public extension DecodedProtocol where Value: OptionalProtocol {
    func filterNil() -> ThrowableDecoded<Value.Wrapped> {
        return .init {
            let optional = try self.value().optional
            guard let value = optional else { throw DecodeError.filtered(value: optional as Any, type: Value.self) }
            return value
        }
    }
}
