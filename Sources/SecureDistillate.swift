public final class SecureDistillate<Value>: Distillate<Value> {
    private let evaluate: () -> Value
    private lazy var cached: Value = self.evaluate()
    
    init(_ evaluate: @escaping () -> Value) {
        self.evaluate = evaluate
    }
    
    override func _value() throws -> Value {
        return value()
    }
    
    public func value() -> Value {
        return cached
    }
}

public extension SecureDistillate {
    @discardableResult
    func value(_ handler: (Value) -> Void) -> SecureDistillate<Value> {
        let v = value()
        handler(v)
        return .init { v }
    }
    
    func to(_: Value.Type) -> Value {
        return value()
    }
}
