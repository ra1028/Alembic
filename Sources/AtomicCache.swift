final class AtomicCache<Value> {
    private let lock = PosixThreadMutex()
    private var _value: Value?
    private var _error: Error?
    
    @discardableResult
    func updatedValue(_ update: (Value?) throws -> Value) throws -> Value {
        lock.lock()
        defer { lock.unlock() }
        
        if let error = _error { throw error }
        
        do {
            let value = try update(_value)
            _value = value
            return value
        } catch let error {
            _error = error
            throw error
        }
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
