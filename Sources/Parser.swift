public struct Parser<Value>: ParserProtocol {
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

public extension Parser {
    static func value(_ value: @autoclosure @escaping () -> Value) -> Parser<Value> {
        return .init(path: [], parser: value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Parser<T> {
        return .init(path: path) { transform(self.value()) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Parser<T>) -> Parser<T> {
        return map { transform($0).value() }
    }
}
