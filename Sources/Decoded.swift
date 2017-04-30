public final class Decoded<Value>: DecodedProtocol {
    private let create: () -> Value
    
    init(_ create: @escaping () -> Value) {
        self.create = create
    }
    
    public func value() -> Value {
        return create()
    }
}

public extension Decoded {
    static func value(_ value: @autoclosure @escaping () -> Value) -> Decoded<Value> {
        return .init(value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> Decoded<T> {
        return .init { transform(self*) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> Decoded<T>) -> Decoded<T> {
        return map(transform)*
    }
}
