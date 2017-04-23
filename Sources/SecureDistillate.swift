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
