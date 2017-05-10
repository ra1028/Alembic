public protocol DecodedProtocol {
    associatedtype Value
    
    var path: JSON.Path { get }
    
    func value() throws -> Value
}

public extension DecodedProtocol {
    func option() throws -> Value? {
        do {
            return try value()
        } catch let JSON.Error.missing(path: missing) where missing == path {
            return nil
        }
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> ThrowDecoded<T> {
        return .init(path: path) {
            do {
                let value = try self.value()
                return try transform(value)
            } catch let error {
                throw error
            }
        }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Decoded<T>) -> ThrowDecoded<T> {
        return _flatMap(transform)
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> ThrowDecoded<T>) -> ThrowDecoded<T> {
        return _flatMap(transform)
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> T?) -> ThrowDecoded<T> {
        return map {
            let optional = try transform($0)
            guard let value = optional else { throw JSON.Error.filtered(value: optional, type: T.self) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> ThrowDecoded<Value> {
        return .init(path: path) {
            let value = try self.value()
            guard try predicate(value) else { throw JSON.Error.filtered(value: value, type: Value.self) }
            return value
        }
    }
}

public extension DecodedProtocol where Value: OptionalProtocol {
    func filterNil() -> ThrowDecoded<Value.Wrapped> {
        return .init(path: path) {
            let optional = try self.value().optional
            guard let value = optional else { throw JSON.Error.filtered(value: optional as Any, type: Value.self) }
            return value
        }
    }
}

private extension DecodedProtocol {
    func _flatMap<T: DecodedProtocol>(_ transform: @escaping (Value) throws -> T) -> ThrowDecoded<T.Value> {
        return map { try transform($0).value() }
    }
}
