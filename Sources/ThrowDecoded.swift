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
    
    public func option() throws -> Value? {
        do {
            return try value()
        } catch let JSON.Error.missing(path: missing) where missing == path {
            return nil
        }
    }
}

public extension ThrowDecoded {
    static func value(_ value: @autoclosure @escaping () throws -> Value) -> ThrowDecoded<Value> {
        return .init(path: [], createValue: value)
    }
    
    static func error(_ error: Error) -> ThrowDecoded<Value> {
        return .init(path: []) { throw error }
    }    
    
    func recover(_ value: @escaping (Error) -> Value) -> Decoded<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch let error { return value(error) }
        }
    }
    
    func recover(with value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return recover { _ in value() }
    }
    
    func mapError(_ transfrom: @escaping (Error) -> Error) -> ThrowDecoded<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch let error { throw transfrom(error) }
        }
    }
    
    func flatMapError(_ transform: @escaping (Error) -> Decoded<Value>) -> Decoded<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch let error { return transform(error).value() }
        }
    }
    
    func flatMapError(_ transform: @escaping (Error) -> ThrowDecoded<Value>) -> ThrowDecoded<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch let error { return try transform(error).value() }
        }
    }
}
