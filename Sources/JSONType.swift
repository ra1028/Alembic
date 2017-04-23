public protocol JSONProtocol {
    func distil<T: Distillable>(_ path: Path, as: T.Type) -> InsecureDistillate<T>
    func option<T: Distillable>(_ path: Path, as: T?.Type) -> InsecureDistillate<T?>
}

public extension JSONProtocol {
    func distil<T: Distillable>(_ path: Path = []) -> InsecureDistillate<T> {
        return distil(path, as: T.self)
    }
    
    func distil<T: Distillable>(_ as: T.Type) -> InsecureDistillate<T> {
        return distil([], as: `as`)
    }
    
    func distil<T: Distillable>(_ path: Path = [], as: [T].Type = [T].self) -> InsecureDistillate<[T]> {
        return .init { try .distil(json: *self.distil(path)) }
    }
    
    func distil<T: Distillable>(_ path: Path = [], as: [String: T].Type = [String: T].self) -> InsecureDistillate<[String: T]> {
        return .init { try .distil(json: *self.distil(path)) }
    }
}

public extension JSONProtocol {
    func option<T: Distillable>(_ path: Path = []) -> InsecureDistillate<T?> {
        return option(path, as: T?.self)
    }
    
    func option<T: Distillable>(_ as: T?.Type) -> InsecureDistillate<T?> {
        return option([], as: `as`)
    }
    
    func option<T: Distillable>(_ path: Path = [], as: [T]?.Type = [T]?.self) -> InsecureDistillate<[T]?> {
        return .init { try self.option(path).value().map([T].distil) }
    }
    
    func option<T: Distillable>(_ path: Path = [], as: [String: T]?.Type = [String: T]?.self) -> InsecureDistillate<[String: T]?> {
        return .init { try self.option(path).value().map([String: T].distil) }
    }
}
