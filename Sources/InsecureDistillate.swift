public final class InsecureDistillate<Value>: Distillate<Value> {
    private let evaluate: () throws -> Value
    private var cached: Value?
    
    init(_ evaluate: @escaping () throws -> Value) {
        self.evaluate = evaluate
    }
    
    override func _value() throws -> Value {
        return try value()
    }
    
    public func value() throws -> Value {
        if let cached = cached { return cached }
        let value = try evaluate()
        self.cached = value
        return value
    }
}

public extension InsecureDistillate {
    func `catch`(_ handler: (Error) -> Value) -> Value {
        do { return try value() }
        catch let e { return handler(e) }
    }
    
    func `catch`(_ handler: @escaping (Error) -> Value) -> SecureDistillate<Value> {
        return .init { self.catch(handler) }
    }
    
    func `catch`(_ element: @autoclosure () -> Value) -> Value {
        return self.catch { _ in element() }
    }
    
    func `catch`( _ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return self.catch { _ in element() }
    }
    
    func mapError(_ f: (Error) throws -> Error) throws -> Value {
        do { return try value() }
        catch let e { throw try f(e) }
    }
    
    func mapError(_ f: @escaping (Error) throws -> Error) -> InsecureDistillate<Value> {
        return .init { try self.mapError(f) }
    }
    
    func flatMapError<T: Distillate<Value>>(_ f: (Error) throws -> T) throws -> Value {
        do { return try value() }
        catch let e { return try f(e)._value() }
    }
    
    func flatMapError<T: Distillate<Value>>(_ f: @escaping (Error) throws -> T) -> InsecureDistillate<Value> {
        return .init { try self.flatMapError(f) }
    }
}
