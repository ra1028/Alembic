public final class InsecureDistillate<Value>: Distillate {
    private let create: () throws -> Value
    private var cachedValue: Value?
    
    init(_ create: @escaping () throws -> Value) {
        self.create = create
    }
    
    public func value() throws -> Value {
        if let cachedValue = cachedValue { return cachedValue }
        let value = try create()
        self.cachedValue = value
        return value
    }
}

public extension InsecureDistillate {
    static var filter: InsecureDistillate<Value> {
        return error(DistillError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> InsecureDistillate<Value> {
        return .init { throw error }
    }
    
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
    
    func flatMapError<T: Distillate>(_ f: (Error) throws -> T) throws -> Value where Value == T.Value {
        do { return try value() }
        catch let e { return try f(e).value() }
    }
    
    func flatMapError<T: Distillate>(_ f: @escaping (Error) throws -> T) -> InsecureDistillate<Value> where Value == T.Value {
        return .init { try self.flatMapError(f) }
    }
}
