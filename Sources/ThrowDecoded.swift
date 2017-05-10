public final class ThrowDecoded<Value>: DecodedProtocol {
    public let path: JSON.Path
    
    private let createValue: () throws -> Value
    
    init(path: JSON.Path, createValue: @escaping () throws -> Value) {
        self.path = path
        self.createValue = createValue
    }
    
    public func value() throws -> Value {
        return try createValue()
    }
}

public extension ThrowDecoded {
    static var filter: ThrowDecoded<Value> {
        return error(JSON.Error.filtered(value: (), type: Value.self))
    }
    
    static func error(_ error: Error) -> ThrowDecoded<Value> {
        return .init(path: []) { throw error }
    }
    
    func recover(with value: @escaping (Error) -> Value) -> Decoded<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch let e { return value(e) }
        }
    }
    
    func recover(_ value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return recover { _ in value() }
    }
    
    func mapError(_ transfrom: @escaping (Error) -> Error) -> ThrowDecoded<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch let e { throw transfrom(e) }
        }
    }
    
    func flatMapError<T: DecodedProtocol>(_ f: @escaping (Error) -> T) -> ThrowDecoded<Value> where T.Value == Value {
        return .init(path: path) {
            do { return try self.value() }
            catch let e { return try f(e).value() }
        }
    }
}
