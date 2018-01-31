public extension JSON {
    public struct Parser<Value>: ParserProtocol {
        public let path: Path
        
        private let parser: () -> Value
        
        init(path: JSON.Path, parser: @escaping () -> Value) {
            self.path = path
            self.parser = parser
        }
        
        public func value() -> Value {
            return parser()
        }
    }
}

public extension JSON.Parser {
    static func value(_ value: @autoclosure @escaping () -> Value) -> JSON.Parser<Value> {
        return .init(path: [], parser: value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> JSON.Parser<T> {
        return .init(path: path) { transform(self.value()) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> JSON.Parser<T>) -> JSON.Parser<T> {
        return map { transform($0).value() }
    }
}
