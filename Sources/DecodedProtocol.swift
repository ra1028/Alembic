public protocol DecodedProtocol {
    associatedtype Value
    
    func value() throws -> Value
}

public extension DecodedProtocol {
    func map<T>(_ transform: @escaping (Value) throws -> T) -> InDecoded<T> {
        return .init { try transform(self.value()) }
    }
    
    func flatMap<T: DecodedProtocol>(_ transform: @escaping (Value) throws -> T) -> InDecoded<T.Value> {
        return .init { try self.map(transform).value().value() }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> T?) -> InDecoded<T> {
        return .init {
            let optional = try self.map(transform).value()
            guard let value = optional else { throw DecodeError.filteredValue(type: T.self, value: optional as Any) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> InDecoded<Value> {
        return .init {
            let v = try self.value()
            guard try predicate(v) else { throw DecodeError.filteredValue(type: Value.self, value: v) }
            return v
        }
    }
}

public extension DecodedProtocol where Value: OptionalProtocol {
    func filterNone() -> InDecoded<Value.Wrapped> {
        return .init { try self.filter { $0.optional != nil }.value().optional! }
    }
}
