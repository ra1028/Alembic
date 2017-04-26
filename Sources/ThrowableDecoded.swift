public final class ThrowableDecoded<Value>: DecodedProtocol {
    private let createValue: () throws -> Value
    private let valueCache = AtomicCache<Value>()
    
    init(_ createValue: @escaping () throws -> Value) {
        self.createValue = createValue
    }
    
    public func value() throws -> Value {
        return try valueCache.updatedValue {
            if let value = $0 { return value }
            return try createValue()
        }
    }
}

public extension ThrowableDecoded {
    static var filter: ThrowableDecoded<Value> {
        return error(DecodeError.filtered(value: (), type: Value.self))
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
