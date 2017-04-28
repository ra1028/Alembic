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
    
    func `catch`(_ value: @escaping (Error) -> Value) -> Decoded<Value> {
        return .init {
            do { return try *self }
            catch let e { return value(e) }
        }
    }
    
    func `catch`( _ value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return self.catch { _ in value() }
    }
    
    func mapError(_ transfrom: @escaping (Error) -> Error) -> ThrowableDecoded<Value> {
        return .init {
            do { return try *self }
            catch let e { throw transfrom(e) }
        }
    }
    
    func flatMapError<T: DecodedProtocol>(_ f: @escaping (Error) -> T) -> ThrowableDecoded<Value> where T.Value == Value {
        return .init {
            do { return try *self }
            catch let e { return try *f(e) }
        }
    }
}
