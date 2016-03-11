import Foundation

public struct DistilResult<Value>: DistilResultType {
    private let process: () throws -> Value
    
    init(process: () throws -> Value) {
        self.process = process
    }
    
    public func to(_: Value.Type) throws -> Value {
        return try process()
    }
    
    public func map<T>(transform: Value throws -> T) throws -> T {
        return try transform(process())
    }
}

public struct DistilCatchedResult<Value>: DistilResultType {
    private let process: () -> Value
    
    init(process: () -> Value) {
        self.process = process
    }
    
    public func to(_: Value.Type) -> Value {
        return process()
    }
    
    public func map<T>(transform: Value throws -> T) throws -> T {
        return try transform(process())
    }
}

public protocol DistilResultType {
    typealias Value
    
    func map<T>(transform: Value throws -> T) throws -> T
}

public extension DistilResultType {
    func map<T>(transform: Value throws -> T) -> DistilResult<T> {
        return DistilResult<T>() {
            try self.map(transform)
        }
    }
    
    func filter(predicate: Value -> Bool) throws -> Value {
        return try map {
            if predicate($0) { return $0 }
            throw DistilError.FilteredValue($0)
        }
    }
    
    func filter(predicate: Value -> Bool) -> DistilResult<Value> {
        return DistilResult() {
            try self.filter(predicate)
        }
    }
    
    func catchUp(with: ErrorType -> Value) -> Value {
        do {
            return try map { $0 }
        } catch let e {
            return with(e)
        }
    }
    
    func catchUp(with: ErrorType -> Value) -> DistilCatchedResult<Value> {
        return DistilCatchedResult() {
            self.catchUp(with)
        }
    }
    
    func catchUp(with: Value) -> Value {
        return catchUp { _ in with }
    }
    
    func catchUp(with: Value) -> DistilCatchedResult<Value> {
        return catchUp { _ in with }
    }
}

public extension DistilResultType where Value: OptionalType {
    func remapNil(with: () -> Value.Wrapped) throws -> Value.Wrapped {
        return try map { $0.optionalValue ?? with() }
    }
    
    func remapNil(with: () -> Value.Wrapped) -> DistilResult<Value.Wrapped> {
        return DistilResult<Value.Wrapped>() {
            try self.remapNil(with)
        }
    }
    
    func remapNil(with: Value.Wrapped) throws -> Value.Wrapped {
        return try remapNil { with }
    }
    
    func remapNil(with: Value.Wrapped) -> DistilResult<Value.Wrapped> {
        return remapNil { with }
    }
    
    func ensure(with: () -> Value.Wrapped) -> Value.Wrapped {
        do {
            return try remapNil(with)
        } catch {
            return with()
        }
    }
    
    func ensure(with: () -> Value.Wrapped) -> DistilCatchedResult<Value.Wrapped> {
        return DistilCatchedResult<Value.Wrapped>() {
            self.ensure(with)
        }
    }
    
    func ensure(with: Value.Wrapped) -> Value.Wrapped {
        return ensure { with }
    }
    
    func ensure(with: Value.Wrapped) -> DistilCatchedResult<Value.Wrapped> {
        return ensure { with }
    }
    
    func filterNil() throws -> Value.Wrapped {
        let value: Value = try filter { $0.optionalValue != nil }
        return value.optionalValue!
    }
    
    func filterNil() -> DistilResult<Value.Wrapped> {
        return DistilResult<Value.Wrapped> {
            try self.filterNil()
        }
    }
}