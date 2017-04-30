public final class ThrowDecoded<Value>: DecodedProtocol {
    private let create: () throws -> Value
    
    init(_ create: @escaping () throws -> Value) {
        self.create = create
    }
    
    public func value() throws -> Value {
        return try create()
    }
}

public extension ThrowDecoded {
    static var filter: ThrowDecoded<Value> {
        return error(DecodeError.filtered(value: (), type: Value.self))
    }
    
    static func error(_ error: Error) -> ThrowDecoded<Value> {
        return .init { throw error }
    }
    
    func recover(with value: @escaping (Error) -> Value) -> Decoded<Value> {
        return .init {
            do { return try self* }
            catch let e { return value(e) }
        }
    }
    
    func recover(_ value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return self.recover { _ in value() }
    }
    
    func mapError(_ transfrom: @escaping (Error) -> Error) -> ThrowDecoded<Value> {
        return .init {
            do { return try self* }
            catch let e { throw transfrom(e) }
        }
    }
    
    func flatMapError<T: DecodedProtocol>(_ f: @escaping (Error) -> T) -> ThrowDecoded<Value> where T.Value == Value {
        return .init {
            do { return try self* }
            catch let e { return try f(e)* }
        }
    }
}
