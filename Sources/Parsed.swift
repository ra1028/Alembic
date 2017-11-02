public struct Parsed<Value>: ParsedProtocol {
    public let path: JSON.Path
    
    private let parser: () -> Value
    
    init(path: JSON.Path, parser: @escaping () -> Value) {
        self.path = path
        self.parser = parser
    }
    
    public func value() -> Value {
        return parser()
    }
}

public extension Parsed {
    static func value(_ value: @autoclosure @escaping () -> Value) -> Parsed<Value> {
        return .init(path: [], parser: value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Parsed<T> {
        return .init(path: path) { transform(self.value()) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Parsed<T>) -> Parsed<T> {
        return map { transform($0).value() }
    }
}
