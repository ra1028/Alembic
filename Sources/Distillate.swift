public protocol Distillate {
    associatedtype Value
    
    func value() throws -> Value
}

public extension Distillate {
    func map<T>(_ transform: @escaping (Value) throws -> T) -> InsecureDistillate<T> {
        return .init { try transform(self.value()) }
    }
    
    func flatMap<T: Distillate>(_ transform: @escaping (Value) throws -> T) -> InsecureDistillate<T.Value> {
        return .init { try self.map(transform).value().value() }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> T?) -> InsecureDistillate<T> {
        return .init {
            let optional = try self.map(transform).value()
            guard let value = optional else { throw DecodeError.filteredValue(type: T.self, value: optional as Any) }
            return value
        }
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> InsecureDistillate<Value> {
        return .init {
            let v = try self.value()
            guard try predicate(v) else { throw DecodeError.filteredValue(type: Value.self, value: v) }
            return v
        }
    }
}

public extension Distillate where Value: OptionalProtocol {
    func filterNone() -> InsecureDistillate<Value.Wrapped> {
        return .init { try self.filter { $0.optional != nil }.value().optional! }
    }
}
