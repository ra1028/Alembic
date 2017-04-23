public protocol Distillate {
    associatedtype Value
    
    func value() throws -> Value
}

public extension Distillate {
    func map<T>(_ transform: (Value) throws -> T) throws -> T {
        return try transform(value())
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> InsecureDistillate<T> {
        return .init { try self.map(transform) }
    }
    
    func flatMap<T: Distillate>(_ transform: (Value) throws -> T) throws -> T.Value {
        return try map(transform).value()
    }
    
    func flatMap<T: Distillate>(_ transform: @escaping (Value) throws -> T) -> InsecureDistillate<T.Value> {
        return .init { try self.flatMap(transform) }
    }
    
    func flatMap<T>(_ transform: (Value) throws -> T?) throws -> T {
        let optional = try map(transform)
        guard let v = optional else { throw DistillError.filteredValue(type: T.self, value: optional as Any) }
        return v
    }
    
    func flatMap<T>(_ transform: @escaping (Value) throws -> T?) -> InsecureDistillate<T> {
        return .init { try self.flatMap(transform) }
    }
    
    func filter(_ predicate: (Value) throws -> Bool) throws -> Value {
        let v = try value()
        guard try predicate(v) else { throw DistillError.filteredValue(type: Value.self, value: v) }
        return v
    }
    
    func filter(_ predicate: @escaping (Value) throws -> Bool) -> InsecureDistillate<Value> {
        return .init { try self.filter(predicate) }
    }
}

public extension Distillate where Value: OptionalProtocol {
    func filterNone() throws -> Value.Wrapped {
        return try filter { $0.optional != nil }.optional!
    }
    
    func filterNone() -> InsecureDistillate<Value.Wrapped> {
        return .init(filterNone)
    }
}
