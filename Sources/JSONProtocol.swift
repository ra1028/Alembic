public protocol JSONProtocol {
    func decode<T: Decodable>(_ path: Path, as: T.Type) -> ThrowableDecoded<T>
    func decodeOption<T: Decodable>(_ path: Path, as: T?.Type) -> ThrowableDecoded<T?>
}

public extension JSONProtocol {
    func decode<T: Decodable>(_ path: Path = []) -> ThrowableDecoded<T> {
        return decode(path, as: T.self)
    }
    
    func decode<T: Decodable>(_ as: T.Type) -> ThrowableDecoded<T> {
        return decode([], as: `as`)
    }
    
    func decode<T: Decodable>(_ path: Path = [], as: [T].Type = [T].self) -> ThrowableDecoded<[T]> {
        return .init { try .value(from: *self.decode(path)) }
    }
    
    func decode<T: Decodable>(_ path: Path = [], as: [String: T].Type = [String: T].self) -> ThrowableDecoded<[String: T]> {
        return .init { try .value(from: *self.decode(path)) }
    }
}

public extension JSONProtocol {
    func decodeOption<T: Decodable>(_ path: Path = []) -> ThrowableDecoded<T?> {
        return decodeOption(path, as: T?.self)
    }
    
    func decodeOption<T: Decodable>(_ as: T?.Type) -> ThrowableDecoded<T?> {
        return decodeOption([], as: `as`)
    }
    
    func decodeOption<T: Decodable>(_ path: Path = [], as: [T]?.Type = [T]?.self) -> ThrowableDecoded<[T]?> {
        return .init { try self.decodeOption(path).value().map([T].value(from:)) }
    }
    
    func decodeOption<T: Decodable>(_ path: Path = [], as: [String: T]?.Type = [String: T]?.self) -> ThrowableDecoded<[String: T]?> {
        return .init { try self.decodeOption(path).value().map([String: T].value(from:)) }
    }
}
