public protocol JSONProtocol {
    func distil<T: Decodable>(_ path: Path, as: T.Type) -> InDecoded<T>
    func option<T: Decodable>(_ path: Path, as: T?.Type) -> InDecoded<T?>
}

public extension JSONProtocol {
    func distil<T: Decodable>(_ path: Path = []) -> InDecoded<T> {
        return distil(path, as: T.self)
    }
    
    func distil<T: Decodable>(_ as: T.Type) -> InDecoded<T> {
        return distil([], as: `as`)
    }
    
    func distil<T: Decodable>(_ path: Path = [], as: [T].Type = [T].self) -> InDecoded<[T]> {
        return .init { try .value(from: *self.distil(path)) }
    }
    
    func distil<T: Decodable>(_ path: Path = [], as: [String: T].Type = [String: T].self) -> InDecoded<[String: T]> {
        return .init { try .value(from: *self.distil(path)) }
    }
}

public extension JSONProtocol {
    func option<T: Decodable>(_ path: Path = []) -> InDecoded<T?> {
        return option(path, as: T?.self)
    }
    
    func option<T: Decodable>(_ as: T?.Type) -> InDecoded<T?> {
        return option([], as: `as`)
    }
    
    func option<T: Decodable>(_ path: Path = [], as: [T]?.Type = [T]?.self) -> InDecoded<[T]?> {
        return .init { try self.option(path).value().map([T].value(from:)) }
    }
    
    func option<T: Decodable>(_ path: Path = [], as: [String: T]?.Type = [String: T]?.self) -> InDecoded<[String: T]?> {
        return .init { try self.option(path).value().map([String: T].value(from:)) }
    }
}
