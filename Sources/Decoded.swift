public final class Decoded<Value>: DecodedProtocol {
    private let createValue: () -> Value
    private let valueCache = AtomicCache<Value>()
    
    init(_ createValue: @escaping () -> Value) {
        self.createValue = createValue
    }
    
    public func value() -> Value {
        return valueCache.updatedValue {
            if let value = $0 { return value }
            return createValue()
        }
    }
}

public extension Decoded {
    static func value(_ value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return .init(value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Decoded<T> {
        return .init { transform(*self) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Decoded<T>) -> Decoded<T> {
        return map(transform).value()
    }
}
