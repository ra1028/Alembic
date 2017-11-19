public struct ThrowParsed<Value>: ParsedProtocol {
    public let path: JSON.Path
    
    private let parser: () throws -> Value
    
    init(path: JSON.Path, parser: @escaping () throws -> Value) {
        self.path = path
        self.parser = parser
    }
    
    public func value() throws -> Value {
        return try parser()
    }
    
    public func option() throws -> Value? {
        do {
            return try value()
        } catch let JSON.Error.missing(path: missing) where missing == path {
            return nil
        }
    }
}

public extension ThrowParsed {
    static func value(_ value: @autoclosure @escaping () throws -> Value) -> ThrowParsed<Value> {
        return .init(path: [], parser: value)
    }
    
    static func error(_ error: Error) -> ThrowParsed<Value> {
        return .init(path: []) { throw error }
    }
    
    func recover(_ value: @escaping (Error) -> Value) -> Parsed<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch { return value(error) }
        }
    }
    
    func recover(with value: @autoclosure @escaping () -> Value) -> Parsed<Value> {
        return recover { _ in value() }
    }
    
    func mapError(_ transfrom: @escaping (Error) -> Error) -> ThrowParsed<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch { throw transfrom(error) }
        }
    }
    
    func flatMapError(_ transform: @escaping (Error) -> Parsed<Value>) -> Parsed<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch { return transform(error).value() }
        }
    }
    
    func flatMapError(_ transform: @escaping (Error) -> ThrowParsed<Value>) -> ThrowParsed<Value> {
        return .init(path: path) {
            do { return try self.value() }
            catch { return try transform(error).value() }
        }
    }
}
