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
        return error(DecodeError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> InsecureDistillate<Value> {
        return .init { throw error }
    }
    
    func `catch`(_ handler: @escaping (Error) -> Value) -> SecureDistillate<Value> {
        return .init {
            do { return try *self }
            catch let e { return handler(e) }
        }
    }
    
    func `catch`( _ element: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return self.catch { _ in element() }
    }
    
    func mapError(_ f: @escaping (Error) throws -> Error) -> InsecureDistillate<Value> {
        return .init {
            do { return try *self }
            catch let e { throw try f(e) }
        }
    }
    
    func flatMapError<T: Distillate>(_ f: @escaping (Error) throws -> T) -> InsecureDistillate<Value> where T.Value == Value {
        return .init {
            do { return try *self }
            catch let e { return try f(e).value() }
        }
    }
}
