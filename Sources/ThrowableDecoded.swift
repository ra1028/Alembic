public final class ThrowableDecoded<Value>: DecodedProtocol {
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

public extension ThrowableDecoded {
    static var filter: ThrowableDecoded<Value> {
        return error(DecodeError.filteredValue(type: Value.self, value: ()))
    }
    
    static func error(_ error: Error) -> ThrowableDecoded<Value> {
        return .init { throw error }
    }
    
    func `catch`(_ handler: @escaping (Error) -> Value) -> Decoded<Value> {
        return .init {
            do { return try *self }
            catch let e { return handler(e) }
        }
    }
    
    func `catch`( _ element: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return self.catch { _ in element() }
    }
    
    func mapError(_ f: @escaping (Error) throws -> Error) -> ThrowableDecoded<Value> {
        return .init {
            do { return try *self }
            catch let e { throw try f(e) }
        }
    }
    
    func flatMapError<T: DecodedProtocol>(_ f: @escaping (Error) throws -> T) -> ThrowableDecoded<Value> where T.Value == Value {
        return .init {
            do { return try *self }
            catch let e { return try f(e).value() }
        }
    }
}
