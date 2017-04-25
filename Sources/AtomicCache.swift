final class AtomicCache<Value> {
    private let lock = PosixThreadMutexLock()
    private var _value: Value?
    
    var value: Value? {
        return updatedOption { $0 }
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
    
    @discardableResult
    func updatedOption(_ update: (Value?) throws -> Value?) throws -> Value? {
        lock.lock()
        defer { lock.unlock() }
        
        _value = try update(_value)
        return _value
    }
    
    @discardableResult
    func updatedOption(_ update: (Value?) -> Value?) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        
        _value = update(_value)
        return _value
    }
}
