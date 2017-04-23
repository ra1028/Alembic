public protocol JSONProtocol {
    func distil<T: Decodable>(_ path: Path, as: T.Type) -> InsecureDistillate<T>
    func option<T: Decodable>(_ path: Path, as: T?.Type) -> InsecureDistillate<T?>
}

public extension JSONProtocol {
    func distil<T: Decodable>(_ path: Path = []) -> InsecureDistillate<T> {
        return distil(path, as: T.self)
    }
    
    func distil<T: Decodable>(_ as: T.Type) -> InsecureDistillate<T> {
        return distil([], as: `as`)
    }
    
    func distil<T: Decodable>(_ path: Path = [], as: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try .value(from: *self.distil(path)) }
    }
    
    func distil<T: Decodable>(_ path: Path = [], as: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try .value(from: *self.distil(path)) }
    }
}

public extension JSONProtocol {
    func option<T: Decodable>(_ path: Path = []) -> InsecureDistillate<T?> {
        return option(path, as: T?.self)
    }
    
    func option<T: Decodable>(_ as: T?.Type) -> InsecureDistillate<T?> {
        return option([], as: `as`)
    }
    
    func option<T: Decodable>(_ path: Path = [], as: [T]?.Type = [T]?.self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path).value().map([T].value(from:)) }
    }
    
    func option<T: Decodable>(_ path: Path = [], as: [String: T]?.Type = [String: T]?.self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path).value().map([String: T].value(from:)) }
    }
}
