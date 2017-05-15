public final class Decoded<Value>: DecodedProtocol {
    public let path: JSON.Path
    
    private let createValue: () -> Value
    
    init(path: JSON.Path, createValue: @escaping () -> Value) {
        self.path = path
        self.createValue = createValue
    }
    
    public func value() -> Value {
        return createValue()
    }
}

public extension Decoded {
    static func value(_ value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return .init(path: [], createValue: value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Decoded<T> {
        return .init(path: path) { transform(self.value()) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Decoded<T>) -> Decoded<T> {
        return map { transform($0).value() }
    }
}
