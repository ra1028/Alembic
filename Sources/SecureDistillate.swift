public final class SecureDistillate<Value>: Distillate {
    private let create: () -> Value
    private lazy var cachedValue: Value = self.create()
    
    init(_ create: @escaping () -> Value) {
        self.create = create
    }
    
    public func value() -> Value {
        return cachedValue
    }
}

public extension SecureDistillate {
    static func value(_ value: @autoclosure @escaping () -> Value) -> SecureDistillate<Value> {
        return .init(value)
    }
    
    func map<T>(_ transform: @escaping (Value) -> T) -> SecureDistillate<T> {
        return .init { transform(*self) }
    }
    
    func flatMap<T>(_ transform: @escaping (Value) -> SecureDistillate<T>) -> SecureDistillate<T> {
        return map(transform).value()
    }
}
