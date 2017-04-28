final class AtomicCache<Value> {
    private let lock = PosixThreadMutex()
    private var _value: Value?
    
    var value: Value? {
        lock.lock()
        defer { lock.unlock() }
        
        return _value
    }
    
    @discardableResult
    func updatedValue(_ update: (Value?) throws -> Value) throws -> Value {
        lock.lock()
        defer { lock.unlock() }
        
        let value = try update(_value)
        _value = value
        return value
    }
    
    @discardableResult
    func updatedValue(_ update: (Value?) -> Value) -> Value {
        lock.lock()
        defer { lock.unlock() }
        
        let value = update(_value)
        _value = value
        return value
    }
}
