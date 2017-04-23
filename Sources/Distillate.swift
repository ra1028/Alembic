public class Distillate<Value> {
    private var cached: Value?
    
    init() {}
    
    func _value() throws -> Value {
        fatalError("Abstract method")
    }
    
    fileprivate func value() throws -> Value {
        if let cached = cached { return cached }
        let value = try _value()
        self.cached = value
        return value
    }
}

public extension Distillate {
    func map<T>(_ transform: (Value) throws -> T) throws -> T {
        return try transform(value())
    }
    
    func map<T>(_ transform: @escaping (Value) throws -> T) -> InsecureDistillate<T> {
        return .init { try self.map(transform) }
    }
    
    func flatMap<T, U: Distillate<T>>(_ transform: (Value) throws -> U) throws -> T {
        return try map(transform).value()
    }
    
    func flatMap<T, U: Distillate<T>>(_ transform: @escaping (Value) throws -> U) -> InsecureDistillate<T> {
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
